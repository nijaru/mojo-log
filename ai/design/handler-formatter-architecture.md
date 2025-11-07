# Handler/Formatter Architecture

**Date:** 2025-11-07
**Status:** Proposed

---

## Architecture Overview

Following the pattern from Python `logging`, Go `slog`, and Rust `tracing`:

```
Logger → Handler(s) → Formatter → Output
```

1. **Logger** - Public API, accepts log calls, dispatches to handlers
2. **Handler** - Determines WHERE to write (file, console, network)
3. **Formatter** - Determines HOW to format (JSON, text, custom)
4. **Output** - FileDescriptor, network socket, buffer, etc.

---

## Trait Design

### Formatter Trait

```mojo
from logger import Level
from .fields import LogFields

trait Formatter:
    """Formats log records into strings."""

    fn format(
        self,
        level: Level,
        msg: String,
        fields: LogFields,
        *,
        timestamp: Optional[String] = None,
        source_location: Optional[String] = None
    ) -> String:
        """Format a log record.

        Args:
            level: Log severity level
            msg: Log message
            fields: Structured key-value fields
            timestamp: Optional timestamp string
            source_location: Optional source file:line

        Returns:
            Formatted log record as string
        """
        ...
```

**Why this signature?**
- All log record data passed explicitly (no hidden state)
- Returns `String` for maximum flexibility
- Optional fields for timestamp/location (handler decides)

### Handler Trait

```mojo
trait Handler:
    """Handles log output to a destination."""

    fn handle(
        mut self,
        level: Level,
        msg: String,
        fields: LogFields
    ) -> None:
        """Handle a log record.

        Args:
            level: Log severity level
            msg: Log message
            fields: Structured key-value fields
        """
        ...

    fn set_level(mut self, level: Level):
        """Set minimum level for this handler."""
        ...

    fn flush(mut self):
        """Flush any buffered output (optional)."""
        pass  # Default no-op

    fn close(mut self):
        """Clean up resources (optional)."""
        pass  # Default no-op
```

**Design notes:**
- Handlers are mutable (maintain internal state)
- Level filtering per-handler (not just global)
- Optional `flush()` and `close()` for resource management

---

## Concrete Implementations

### JSONFormatter

```mojo
struct JSONFormatter(Formatter):
    """Formats logs as JSON."""

    var include_timestamp: Bool
    var include_source: Bool

    fn __init__(
        out self,
        *,
        include_timestamp: Bool = True,
        include_source: Bool = False
    ):
        self.include_timestamp = include_timestamp
        self.include_source = include_source

    fn format(
        self,
        level: Level,
        msg: String,
        fields: LogFields,
        *,
        timestamp: Optional[String] = None,
        source_location: Optional[String] = None
    ) -> String:
        var result = String("{")

        # Required fields
        result += '"level":"' + str(level) + '",'
        result += '"msg":"' + escape_json(msg) + '"'

        # Optional timestamp
        if self.include_timestamp and timestamp:
            result += ',"timestamp":"' + timestamp.value() + '"'

        # Optional source location
        if self.include_source and source_location:
            result += ',"source":"' + source_location.value() + '"'

        # Structured fields
        for item in fields.data.items():
            result += ',"' + item.key + '":' + format_json_value(item.value)

        result += "}"
        return result
```

**Output example:**
```json
{"level":"INFO","msg":"user login","timestamp":"2025-11-07T10:30:45Z","user_id":123,"ip":"192.168.1.1"}
```

### TextFormatter

```mojo
struct TextFormatter(Formatter):
    """Formats logs as human-readable text."""

    var include_timestamp: Bool
    var include_source: Bool
    var colorize: Bool

    fn __init__(
        out self,
        *,
        include_timestamp: Bool = True,
        include_source: Bool = False,
        colorize: Bool = False
    ):
        self.include_timestamp = include_timestamp
        self.include_source = include_source
        self.colorize = colorize

    fn format(
        self,
        level: Level,
        msg: String,
        fields: LogFields,
        *,
        timestamp: Optional[String] = None,
        source_location: Optional[String] = None
    ) -> String:
        var result = String()

        # Timestamp
        if self.include_timestamp and timestamp:
            result += "[" + timestamp.value() + "] "

        # Level (with color if enabled)
        if self.colorize:
            result += colorize_level(level) + " "
        else:
            result += str(level) + ": "

        # Message
        result += msg

        # Fields (key=value format)
        if not fields.data.empty():
            result += " "
            var first = True
            for item in fields.data.items():
                if not first:
                    result += " "
                result += item.key + "=" + format_text_value(item.value)
                first = False

        # Source location
        if self.include_source and source_location:
            result += " (" + source_location.value() + ")"

        return result
```

**Output example:**
```
[2025-11-07T10:30:45Z] INFO: user login user_id=123 ip=192.168.1.1 (main.mojo:42)
```

### ConsoleHandler

```mojo
struct ConsoleHandler(Handler):
    """Writes logs to stdout/stderr."""

    var formatter: Formatter
    var min_level: Level
    var fd: FileDescriptor

    fn __init__(
        out self,
        formatter: Formatter,
        *,
        min_level: Level = Level.INFO,
        use_stderr: Bool = False
    ):
        self.formatter = formatter
        self.min_level = min_level
        self.fd = FileDescriptor(2 if use_stderr else 1)

    fn handle(
        mut self,
        level: Level,
        msg: String,
        fields: LogFields
    ):
        # Level filtering
        if level < self.min_level:
            return

        # Format and write
        var timestamp = get_timestamp()  # Platform-specific
        var formatted = self.formatter.format(
            level, msg, fields,
            timestamp=timestamp
        )

        self.fd.write(formatted, "\n")

    fn set_level(mut self, level: Level):
        self.min_level = level

    fn flush(mut self):
        # FileDescriptor writes are unbuffered by default
        pass
```

### FileHandler

```mojo
struct FileHandler(Handler):
    """Writes logs to a file."""

    var formatter: Formatter
    var min_level: Level
    var file_path: String
    var fd: Optional[FileDescriptor]

    fn __init__(
        out self,
        file_path: String,
        formatter: Formatter,
        *,
        min_level: Level = Level.INFO,
        mode: String = "a"  # append by default
    ):
        self.formatter = formatter
        self.min_level = min_level
        self.file_path = file_path
        self.fd = None
        self._open(mode)

    fn _open(mut self, mode: String):
        """Open the log file."""
        try:
            var f = open(self.file_path, mode)
            self.fd = f.fd  # Extract FileDescriptor
        except e:
            # Handle file opening error
            print("Failed to open log file:", self.file_path)

    fn handle(
        mut self,
        level: Level,
        msg: String,
        fields: LogFields
    ):
        if level < self.min_level:
            return

        if not self.fd:
            return  # File not open

        var timestamp = get_timestamp()
        var formatted = self.formatter.format(
            level, msg, fields,
            timestamp=timestamp
        )

        self.fd.value().write(formatted, "\n")

    fn set_level(mut self, level: Level):
        self.min_level = level

    fn flush(mut self):
        # Could add buffering later
        pass

    fn close(mut self):
        # FileDescriptor closes automatically
        self.fd = None
```

---

## Logger Integration

```mojo
struct Logger:
    """Main logging interface."""

    var handlers: List[Handler]
    var min_level: Level  # Global minimum level

    fn __init__(
        out self,
        *handlers: Handler,
        min_level: Level = Level.INFO
    ):
        self.handlers = List[Handler]()
        for handler in handlers:
            self.handlers.append(handler)
        self.min_level = min_level

    fn info(self, msg: String, fields: LogFields = LogFields()):
        self._log(Level.INFO, msg, fields)

    fn warning(self, msg: String, fields: LogFields = LogFields()):
        self._log(Level.WARNING, msg, fields)

    fn error(self, msg: String, fields: LogFields = LogFields()):
        self._log(Level.ERROR, msg, fields)

    fn _log(self, level: Level, msg: String, fields: LogFields):
        # Global level check
        if level < self.min_level:
            return

        # Dispatch to all handlers
        for handler in self.handlers:
            handler[].handle(level, msg, fields)
```

---

## Usage Examples

### Example 1: Console Only

```mojo
from mojo_log import Logger, ConsoleHandler, TextFormatter

fn main():
    var formatter = TextFormatter()
    var handler = ConsoleHandler(formatter)
    var logger = Logger(handler)

    var fields = LogFields()
    fields.add_int("user_id", 123)
    fields.add_string("action", "login")

    logger.info("User logged in", fields)
```

**Output:**
```
[2025-11-07T10:30:45Z] INFO: User logged in user_id=123 action=login
```

### Example 2: JSON to File + Console

```mojo
from mojo_log import Logger, ConsoleHandler, FileHandler, JSONFormatter, TextFormatter

fn main():
    # JSON to file
    var json_formatter = JSONFormatter()
    var file_handler = FileHandler("/var/log/app.log", json_formatter)

    # Text to console
    var text_formatter = TextFormatter(colorize=True)
    var console_handler = ConsoleHandler(text_formatter)

    # Logger with both handlers
    var logger = Logger(file_handler, console_handler)

    var fields = LogFields()
    fields.add_int("response_time_ms", 42)

    logger.info("Request completed", fields)
```

**File output (JSON):**
```json
{"level":"INFO","msg":"Request completed","timestamp":"2025-11-07T10:30:45Z","response_time_ms":42}
```

**Console output (colored text):**
```
[2025-11-07T10:30:45Z] INFO: Request completed response_time_ms=42
```

### Example 3: Per-Handler Level Filtering

```mojo
fn main():
    # Debug to file
    var file_formatter = JSONFormatter()
    var file_handler = FileHandler("/var/log/debug.log", file_formatter, min_level=Level.DEBUG)

    # Only warnings/errors to console
    var console_formatter = TextFormatter()
    var console_handler = ConsoleHandler(console_formatter, min_level=Level.WARNING)

    var logger = Logger(file_handler, console_handler, min_level=Level.DEBUG)

    logger.debug("Debug info")      # → File only
    logger.info("Info message")     # → File only
    logger.warning("Warning!")      # → File + Console
    logger.error("Error occurred!") # → File + Console
```

---

## Handler Ownership

**Question:** Should Logger own handlers or reference them?

### Option A: Owned (RECOMMENDED for MVP)
```mojo
struct Logger:
    var handlers: List[Handler]  # Logger owns handlers
```

**Pros:**
- ✅ Simpler lifecycle management
- ✅ No lifetime/reference complexity
- ✅ Handlers automatically cleaned up

**Cons:**
- ❌ Can't share handlers between loggers
- ❌ Slightly less flexible

### Option B: Referenced
```mojo
struct Logger:
    var handlers: List[Reference[Handler]]  # Logger references handlers
```

**Pros:**
- ✅ Can share handlers

**Cons:**
- ❌ Complex lifetime management
- ❌ Mojo's reference system still evolving

**Decision:** Use ownership for MVP. Add reference support in future if needed.

---

## Formatter Ownership in Handlers

Same question for formatters in handlers.

**Decision:** Handlers own formatters (stored by value).

```mojo
struct ConsoleHandler(Handler):
    var formatter: Formatter  # Owned, not referenced
```

**Alternative:** If formatters become complex/large, use reference counting (future).

---

## Thread Safety

**For MVP:** Handlers are NOT thread-safe.

**Documentation:**
> **Warning:** Handlers are not thread-safe. If logging from multiple threads, users must provide external synchronization or use thread-local loggers.

**Future work:**
- Add `SyncHandler` wrapper with mutex (when Mojo stdlib adds mutexes)
- Add async/buffered handlers for performance

---

## Open Questions

1. **Handler initialization ergonomics?** Current API requires creating formatter first.
   - Could add factory methods: `ConsoleHandler.with_json()`
2. **Buffering strategy?** All writes are currently unbuffered.
   - Future: Add `BufferedHandler` wrapper
3. **Error handling?** What if file write fails?
   - For MVP: Silent failure (log to stderr?)
   - Future: Error callbacks, fallback handlers
4. **Dynamic handler registration?** Add/remove handlers at runtime?
   - For MVP: Handlers set at construction only
   - Future: `logger.add_handler()`, `logger.remove_handler()`

---

## Performance Considerations

### Allocation

- Formatting produces new `String` objects (heap allocation)
- For hot paths, consider:
  - Pre-allocated buffers (future)
  - Zero-allocation formatting (future)
  - Compile-time level checks (leverage stdlib.logger)

### Optimization Ideas

1. **Inline small formatters** with `@always_inline`
2. **Compile-time specialization** per handler type
3. **SIMD for JSON escaping** (future)
4. **Lock-free ring buffers** for async logging (future)

---

## Compatibility with stdlib.logger

Our `Logger` wraps but doesn't expose stdlib's `Logger` directly.

**Integration point:**
```mojo
from logger import Logger as StdLogger, Level as StdLevel

struct Logger:
    var _stdlib_logger: StdLogger[StdLevel.INFO]  # For compile-time filtering
    var handlers: List[Handler]

    fn _log(self, level: Level, msg: String, fields: LogFields):
        # Use stdlib for compile-time level check
        if level >= Level.INFO:  # Compile-time
            # Runtime dispatch to handlers
            for handler in self.handlers:
                handler[].handle(level, msg, fields)
```

**Benefit:** Zero overhead when log level is filtered out at compile-time.
