# mojo-log

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

Structured logging library for Mojo with flexible formatters and handlers.

## Features

- 🏗️ **Structured Logging** - Type-safe key-value fields (Int, Float64, String, Bool)
- 🎨 **Multiple Formatters** - JSON and human-readable text output
- 📝 **Flexible Handlers** - Console (stdout/stderr) output with pluggable architecture
- 🎯 **Level Filtering** - Per-handler minimum level configuration
- 🔧 **Composable** - Mix and match formatters and handlers
- ⚡ **Type-Safe** - Leverages Mojo's type system and traits

## Quick Start

```mojo
from logger import Level
from mojo_log import Logger, LogFields
from mojo_log.formatters import TextFormatter
from mojo_log.handlers import ConsoleHandler

fn main():
    # Create a logger with text output
    var logger = Logger(ConsoleHandler(
        TextFormatter(),
        min_level=Level.INFO,
    ))

    # Simple logging
    logger.info("Application started")

    # Structured logging with fields
    var fields = LogFields()
    fields.add_int("user_id", 123)
    fields.add_string("action", "login")
    fields.add_bool("success", True)

    logger.info("User action", fields)
    # Output: INFO: User action user_id=123 action=login success=true
```

## Installation

1. Clone the repository:
```bash
git clone https://github.com/nijaru/mojo-log.git
cd mojo-log
```

2. Run tests:
```bash
mojo run -I . tests/test_fields.mojo
mojo run -I . tests/test_formatters.mojo
mojo run -I . tests/test_handlers.mojo
mojo run -I . tests/test_logger.mojo
```

3. Run examples:
```bash
mojo run -I . examples/basic_usage.mojo
```

## Usage

### Text Formatter

```mojo
from mojo_log import Logger, LogFields
from mojo_log.formatters import TextFormatter
from mojo_log.handlers import ConsoleHandler

var logger = Logger(ConsoleHandler(TextFormatter()))

logger.info("Processing request")
// Output: INFO: Processing request

var fields = LogFields()
fields.add_string("method", "GET")
fields.add_int("status", 200)
logger.info("Request complete", fields)
// Output: INFO: Request complete method=GET status=200
```

### JSON Formatter

```mojo
from mojo_log.formatters import JSONFormatter

var logger = Logger(ConsoleHandler(JSONFormatter()))

var fields = LogFields()
fields.add_int("request_id", 789)
fields.add_float("duration_ms", 42.5)
logger.info("API call", fields)
// Output: {"level":"INFO","msg":"API call","request_id":789,"duration_ms":42.5}
```

### Log Levels

```mojo
logger.trace("Detailed trace information")    // Level.TRACE
logger.debug("Debug information")             // Level.DEBUG
logger.info("General information")            // Level.INFO
logger.warning("Warning message")             // Level.WARNING
logger.error("Error occurred")                // Level.ERROR
logger.critical("Critical failure")           // Level.CRITICAL
```

### Level Filtering

```mojo
// Only log WARNING and above
var logger = Logger(ConsoleHandler(
    TextFormatter(),
    min_level=Level.WARNING,
))

logger.debug("Debug")    // Filtered out
logger.info("Info")      // Filtered out
logger.warning("Warn")   // Shown
logger.error("Error")    // Shown
```

### Dynamic Level Changes

```mojo
var logger = Logger(ConsoleHandler(
    TextFormatter(),
    min_level=Level.INFO,
))

logger.debug("Debug 1")  // Filtered

logger.set_level(Level.DEBUG)

logger.debug("Debug 2")  // Now shown
```

### Structured Fields

```mojo
var fields = LogFields()

// Type-safe field methods
fields.add_int("count", 42)
fields.add_float("ratio", 3.14)
fields.add_string("name", "test")
fields.add_bool("active", True)

logger.info("Event occurred", fields)
```

## Architecture

```
Logger → Handler → Formatter → Output
```

- **Logger**: Main entry point, provides level-specific methods
- **Handler**: Processes log records and sends to output (e.g., ConsoleHandler)
- **Formatter**: Converts log records to strings (e.g., TextFormatter, JSONFormatter)
- **LogFields**: Type-safe structured field storage using Variant

## API Reference

### Logger[HandlerType]

Main logging interface.

**Methods:**
- `trace(msg: String, fields: LogFields = LogFields())`
- `debug(msg: String, fields: LogFields = LogFields())`
- `info(msg: String, fields: LogFields = LogFields())`
- `warning(msg: String, fields: LogFields = LogFields())`
- `error(msg: String, fields: LogFields = LogFields())`
- `critical(msg: String, fields: LogFields = LogFields())`
- `set_level(level: Level)` - Change minimum log level
- `flush()` - Flush buffered output
- `close()` - Clean up resources

### LogFields

Container for structured key-value fields.

**Methods:**
- `add_int(key: String, value: Int)`
- `add_float(key: String, value: Float64)`
- `add_string(key: String, value: String)`
- `add_bool(key: String, value: Bool)`
- `contains(key: String) -> Bool`
- `__len__() -> Int`

### Formatters

#### TextFormatter

Human-readable key=value format.

```mojo
TextFormatter()
```

Output: `INFO: message key1=value1 key2=value2`

#### JSONFormatter

Compact JSON format.

```mojo
JSONFormatter()
```

Output: `{"level":"INFO","msg":"message","key1":"value1","key2":"value2"}`

### Handlers

#### ConsoleHandler[FormatterType]

Writes logs to stdout or stderr.

```mojo
ConsoleHandler[FormatterType](
    formatter: FormatterType,
    min_level: Level = Level.INFO,
    use_stderr: Bool = False,
)
```

## Development

### Project Structure

```
mojo-log/
├── mojo_log/
│   ├── __init__.mojo          # Public exports
│   ├── logger.mojo            # Logger struct
│   ├── fields.mojo            # LogFields, LogValue
│   ├── handler.mojo           # Handler trait
│   ├── formatter.mojo         # Formatter trait
│   ├── handlers/
│   │   ├── __init__.mojo
│   │   └── console.mojo       # ConsoleHandler
│   └── formatters/
│       ├── __init__.mojo
│       ├── json.mojo          # JSONFormatter
│       └── text.mojo          # TextFormatter
├── tests/
│   ├── test_fields.mojo
│   ├── test_formatters.mojo
│   ├── test_handlers.mojo
│   └── test_logger.mojo
└── examples/
    └── basic_usage.mojo
```

### Running Tests

```bash
# Run individual test suites
mojo run -I . tests/test_fields.mojo
mojo run -I . tests/test_formatters.mojo
mojo run -I . tests/test_handlers.mojo
mojo run -I . tests/test_logger.mojo

# Run all tests
for test in tests/test_*.mojo; do mojo run -I . "$test"; done
```

## Roadmap

MVP (v0.1.0) - ✅ Complete:
- ✅ LogFields with Variant-based values
- ✅ Formatter trait (JSON, Text)
- ✅ Handler trait (Console)
- ✅ Logger struct
- ✅ Comprehensive tests
- ✅ Examples

Future:
- [ ] FileHandler with rotation
- [ ] Async handlers
- [ ] Custom formatters
- [ ] Performance benchmarks
- [ ] Additional field types (lists, nested structures)
- [ ] Timestamp support
- [ ] Source location tracking

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

## Acknowledgments

- Inspired by structured logging libraries like slog (Go), Logrus (Go), and structlog (Python)
- Built with [Mojo](https://www.modular.com/mojo) 🔥
