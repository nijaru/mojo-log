# mojo-log

Production logging for Mojo 🔥

## Project Overview

A structured logging library for Mojo that extends `stdlib.logger` with modern production features.

## Goals

- Structured logging with key-value fields
- Multiple output handlers (console, file, remote)
- JSON and text formatters
- Fast (leverage Mojo's compile-time optimizations)
- Simple API (inspired by Go slog)
- Extend stdlib, don't replace it

## Architecture

```
Logger → Handler(s) → Formatter → Output
          ↓
       Filter (level, module)
```

## Status

Early development - API design phase

See `ai/STATUS.md` for current progress.

## Development Resources

### Mojo Documentation References

**Primary:** Local Modular/Mojo repository at `~/github/modular/modular`
- Up-to-date Mojo source code and examples
- Latest stdlib implementations
- Official documentation and changelogs
- Use this for authoritative information about Mojo features

**Online:**
- https://docs.modular.com/mojo/
- https://docs.modular.com/mojo/stdlib/

### Design Documents

See `ai/` directory for:
- `ai/STATUS.md` - Current state and next steps
- `ai/DECISIONS.md` - Architecture decisions with rationales
- `ai/design/` - API design, architecture specs
- `ai/research/` - Mojo language research findings
