# mojo-log API Design

**Date:** 2025-11-07
**Version:** 0.1.0 MVP
**Status:** Proposed

---

## Design Principles

1. **Simple by default** - Common use cases should be one-liners
2. **Structured first** - Encourage key-value fields over string interpolation
3. **Type-safe** - Leverage Mojo's type system for correctness
4. **Composable** - Mix and match handlers/formatters
5. **Performant** - Zero-cost abstractions where possible

---

## Module Structure

```
mojo_log/
├── __init__.mojo          # Public exports
├── logger.mojo            # Logger struct
├── level.mojo             # Log levels (re-export from stdlib)
├── fields.mojo            # LogFields, LogValue types
├── handler.mojo           # Handler trait
├── formatter.mojo         # Formatter trait
├── handlers/
│   ├── __init__.mojo
│   ├── console.mojo       # ConsoleHandler
│   └── file.mojo          # FileHandler
└── formatters/
    ├── __init__.mojo
    ├── json.mojo          # JSONFormatter
    └── text.mojo          # TextFormatter
```

---

## Public API

### Core Types

```mojo
# Level (re-exported from stdlib.logger)
from logger import Level

alias TRACE    = Level.TRACE
alias DEBUG    = Level.DEBUG
alias INFO     = Level.INFO
alias WARNING  = Level.WARNING
alias ERROR    = Level.ERROR
alias CRITICAL = Level.CRITICAL

# Log value types
alias LogValue = Variant[Int, Float64, String, Bool]

struct LogFields:
    var data: Dict[String, LogValue]

    fn __init__(out self): ...
    fn add_int(mut self, key: String, value: Int): ...
    fn add_float(mut self, key: String, value: Float64): ...
    fn add_string(mut self, key: String, value: String): ...
    fn add_bool(mut self, key: String, value: Bool): ...

# Logger
struct Logger:
    fn __init__(out self, *handlers: Handler, min_level: Level = Level.INFO): ...

    fn trace(self, msg: String, fields: LogFields = LogFields()): ...
    fn debug(self, msg: String, fields: LogFields = LogFields()): ...
    fn info(self, msg: String, fields: LogFields = LogFields()): ...
    fn warning(self, msg: String, fields: LogFields = LogFields()): ...
    fn error(self, msg: String, fields: LogFields = LogFields()): ...
    fn critical(self, msg: String, fields: LogFields = LogFields()): ...
```

### Traits

```mojo
trait Formatter:
    fn format(
        self,
        level: Level,
        msg: String,
        fields: LogFields,
        *,
        timestamp: Optional[String] = None,
        source_location: Optional[String] = None
    ) -> String: ...

trait Handler:
    fn handle(mut self, level: Level, msg: String, fields: LogFields) -> None: ...
    fn set_level(mut self, level: Level): ...
    fn flush(mut self): ...
    fn close(mut self): ...
```

### Formatters

```mojo
struct JSONFormatter(Formatter):
    fn __init__(
        out self,
        *,
        include_timestamp: Bool = True,
        include_source: Bool = False
    ): ...

struct TextFormatter(Formatter):
    fn __init__(
        out self,
        *,
        include_timestamp: Bool = True,
        include_source: Bool = False,
        colorize: Bool = False
    ): ...
```

### Handlers

```mojo
struct ConsoleHandler(Handler):
    fn __init__(
        out self,
        formatter: Formatter,
        *,
        min_level: Level = Level.INFO,
        use_stderr: Bool = False
    ): ...

struct FileHandler(Handler):
    fn __init__(
        out self,
        file_path: String,
        formatter: Formatter,
        *,
        min_level: Level = Level.INFO,
        mode: String = "a"
    ): ...
```

---

## Usage Examples

### Example 1: Quickstart (Console, Text Format)

```mojo
from mojo_log import Logger, ConsoleHandler, TextFormatter

fn main():
    var logger = Logger(
        ConsoleHandler(TextFormatter())
    )

    logger.info("Application started")
    logger.warning("Low memory")
    logger.error("Connection failed")
```

**Output:**
```
[2025-11-07T10:30:45Z] INFO: Application started
[2025-11-07T10:30:46Z] WARNING: Low memory
[2025-11-07T10:30:47Z] ERROR: Connection failed
```

### Example 2: Structured Logging

```mojo
from mojo_log import Logger, ConsoleHandler, JSONFormatter, LogFields

fn main():
    var logger = Logger(
        ConsoleHandler(JSONFormatter())
    )

    var fields = LogFields()
    fields.add_int("user_id", 12345)
    fields.add_string("ip", "192.168.1.1")
    fields.add_bool("authenticated", True)

    logger.info("user login", fields)
```

**Output (JSON):**
```json
{"level":"INFO","msg":"user login","timestamp":"2025-11-07T10:30:45Z","user_id":12345,"ip":"192.168.1.1","authenticated":true}
```

### Example 3: Multiple Handlers (File + Console)

```mojo
from mojo_log import (
    Logger,
    ConsoleHandler,
    FileHandler,
    JSONFormatter,
    TextFormatter,
    LogFields
)

fn main():
    # JSON to file for structured data
    var file_handler = FileHandler(
        "/var/log/app.log",
        JSONFormatter()
    )

    # Human-readable to console
    var console_handler = ConsoleHandler(
        TextFormatter(colorize=True)
    )

    var logger = Logger(file_handler, console_handler)

    var fields = LogFields()
    fields.add_float("response_time", 0.042)
    fields.add_int("status_code", 200)

    logger.info("request completed", fields)
}
```

**Console (colored):**
```
[2025-11-07T10:30:45Z] INFO: request completed response_time=0.042 status_code=200
```

**File (JSON):**
```json
{"level":"INFO","msg":"request completed","timestamp":"2025-11-07T10:30:45Z","response_time":0.042,"status_code":200}
```

### Example 4: Per-Handler Level Filtering

```mojo
from mojo_log import Logger, ConsoleHandler, FileHandler, TextFormatter, Level

fn main():
    # File: capture everything
    var file_handler = FileHandler(
        "/var/log/debug.log",
        TextFormatter(),
        min_level=Level.DEBUG
    )

    # Console: only warnings and errors
    var console_handler = ConsoleHandler(
        TextFormatter(colorize=True),
        min_level=Level.WARNING
    )

    # Global minimum: DEBUG (so file handler gets debug logs)
    var logger = Logger(
        file_handler,
        console_handler,
        min_level=Level.DEBUG
    )

    logger.debug("Debug info")      # → File only
    logger.info("Info message")     # → File only
    logger.warning("Warning!")      # → File + Console
    logger.error("Error occurred!") # → File + Console
}
```

### Example 5: Custom Formatter

```mojo
from mojo_log import Formatter, Level, LogFields

struct CompactFormatter(Formatter):
    """Ultra-compact log format."""

    fn format(
        self,
        level: Level,
        msg: String,
        fields: LogFields,
        *,
        timestamp: Optional[String] = None,
        source_location: Optional[String] = None
    ) -> String:
        # Format: LEVEL|msg|key=val|key=val
        var result = str(level) + "|" + msg

        for item in fields.data.items():
            result += "|" + item.key + "=" + str(item.value)

        return result

# Usage
fn main():
    var logger = Logger(
        ConsoleHandler(CompactFormatter())
    )

    var fields = LogFields()
    fields.add_int("code", 404)

    logger.error("Not found", fields)
    # Output: ERROR|Not found|code=404
}
```

---

## Design Decisions

### Why Separate LogFields?

**Alternative:** Use variadic kwargs:
```mojo
logger.info("user login", user_id=123, ip="192.168.1.1")  # If Mojo supports
```

**Reason for LogFields:**
- Mojo doesn't have Python-style kwargs yet
- Explicit types (add_int, add_string) avoid ambiguity
- Can be passed around, composed, reused

### Why Handler Trait Instead of Callbacks?

**Alternative:** Accept functions:
```mojo
logger.add_handler(fn(level, msg, fields) -> None { ... })
```

**Reason for Trait:**
- Handlers have state (file descriptors, buffers, config)
- Need lifecycle methods (flush, close)
- More extensible (can add methods later)

### Why No Global Logger?

**Alternative:** Singleton like Python's logging:
```mojo
import mojo_log
mojo_log.info("message")  # Uses global logger
```

**Reason:**
- Explicit > implicit (Mojo philosophy)
- Easier testing (inject logger)
- No global state complexity
- Can add convenience wrapper later if needed

### Why No Async/Buffered Handlers in MVP?

**Future:**
```mojo
struct AsyncHandler(Handler):
    """Logs asynchronously to avoid blocking."""
    var ring_buffer: RingBuffer[LogRecord]
    var worker_thread: Thread
```

**Reason:**
- MVP scope management
- Requires robust concurrency primitives
- Most use cases don't need it initially

---

## Performance Characteristics

### Compile-Time Level Filtering

```mojo
struct Logger[level: Level]:  # Compile-time parameter
    fn debug(self, msg: String, fields: LogFields = LogFields()):
        @parameter
        if level <= Level.DEBUG:  # Compile-time check
            self._log(Level.DEBUG, msg, fields)
        # If level > DEBUG, this is completely optimized out
```

**Benefit:** Zero-cost debug logging when compiled for production.

### Allocation Profile (Per Log Call)

| Operation | Allocations |
|-----------|-------------|
| LogFields creation | 1 (Dict allocation) |
| Adding N fields | N * sizeof(LogValue) |
| Formatting to String | 1-2 (String + potential resizes) |
| Writing to FileDescriptor | 0 (unbuffered) |

**Total:** ~2-4 heap allocations per log call (MVP acceptable).

### Future Optimizations

1. **Object pooling** for LogFields
2. **Pre-allocated buffers** for formatting
3. **SIMD string operations** for JSON escaping
4. **Lock-free ring buffers** for async logging

---

## Error Handling

### File Opening Errors

```mojo
var handler = FileHandler("/invalid/path", JSONFormatter())
# Current: Silent failure (prints to stderr)
# Future: Return Result[FileHandler, Error] or raise
```

### Write Failures

```mojo
logger.info("message")  # What if disk full?
# Current: Silent failure
# Future: Error callbacks, fallback handlers
```

**For MVP:** Fail silently to avoid crashing applications. Log errors to stderr.

---

## Testing Strategy

### Unit Tests

```mojo
fn test_log_fields():
    var fields = LogFields()
    fields.add_int("x", 42)

    assert(fields.data["x"].isa[Int]())
    assert(fields.data["x"][Int] == 42)

fn test_json_formatter():
    var formatter = JSONFormatter()
    var fields = LogFields()
    fields.add_string("key", "value")

    var output = formatter.format(Level.INFO, "test", fields)
    assert('"key":"value"' in output)
```

### Integration Tests

```mojo
fn test_file_handler():
    var temp_file = "/tmp/test_log.json"
    var handler = FileHandler(temp_file, JSONFormatter())
    var logger = Logger(handler)

    logger.info("test message")
    handler.flush()

    # Read file and verify content
    var content = read_file(temp_file)
    assert('{"level":"INFO"' in content)
```

---

## Migration from stdlib.logger

```mojo
# Before (stdlib.logger)
from logger import Logger
var log = Logger()
log.info("message")

# After (mojo-log)
from mojo_log import Logger, ConsoleHandler, TextFormatter
var logger = Logger(ConsoleHandler(TextFormatter()))
logger.info("message")
```

**Migration guide:**
1. Replace `Logger()` with `Logger(ConsoleHandler(TextFormatter()))`
2. Add structured fields where applicable
3. Configure handlers for different outputs

---

## Documentation Plan

1. **README.md** - Quickstart + examples
2. **API Reference** - Auto-generated from docstrings
3. **User Guide**:
   - Logging basics
   - Structured fields
   - Handlers and formatters
   - Custom handlers/formatters
   - Performance tuning
4. **Examples/** - Real-world use cases

---

## Open Questions for Implementation

1. **Timestamp generation?**
   - Platform-specific: `time.now()` if available
   - Or require user to pass timestamp?
2. **Source location tracking?**
   - Mojo's `@location` intrinsic?
   - Or require explicit passing?
3. **String escaping for JSON?**
   - Comprehensive (slow) or minimal (fast)?
4. **Level enum representation?**
   - Re-export stdlib's Level or define our own?

**Decision:** Address during implementation based on stdlib capabilities.
