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
