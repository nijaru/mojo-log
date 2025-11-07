# mojo-log 🔥

Production logging for Mojo - structured, fast, and extensible.

## Status

🚧 **Early Development** - API design in progress

## Goals

- **Structured logging** - Key-value fields, not just strings
- **Multiple outputs** - Log to console, files, and remote services simultaneously
- **JSON + Text formats** - Machine-parseable and human-readable
- **Fast** - Leverages Mojo's compile-time optimizations
- **Extends stdlib** - Built on top of `stdlib.logger`, not replacing it

## Planned API

```mojo
from mojo_log import Logger, JSONHandler, ConsoleHandler

var logger = Logger(
    JSONHandler("/var/log/app.log"),
    ConsoleHandler()
)

logger.info("user login",
    user_id=123,
    ip="192.168.1.1")
```

## Roadmap

- [ ] Core logger with structured fields
- [ ] JSON formatter
- [ ] Text formatter
- [ ] Multiple handler support
- [ ] Child loggers (contextual binding)
- [ ] Async buffering
- [ ] Log rotation

## License

Apache 2.0
