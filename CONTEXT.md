# mojo-log Context (for Claude Code sessions)

Quick reference for resuming development

## Quick Summary

Building **mojo-log**: a structured logging library for Mojo that extends `stdlib.logger` with production features (JSON, multiple handlers, structured fields).

**Status:** API design phase
**Repo:** https://github.com/nijaru/mojo-log (public, Apache 2.0)
**Competition:** ZERO (first structured logger for Mojo)

---

## Key Decisions (see ai/DECISIONS.md)

1. **Name:** `mojo-log` (simple > clever puns)
2. **Extend stdlib.logger** (don't replace/fork)
3. **Minimal JSON encoder** (no EmberJson dependency for MVP)
4. **Handler/Formatter architecture** (proven pattern from Python/Go)
5. **Simple API:** `Logger` not `StructuredLogger`

---

## What We Researched (see ai/RESEARCH.md)

**stdlib.logger:**
- Has: 7 levels, compile-time filtering, FileDescriptor output
- Missing: structured fields, JSON, multiple handlers, child loggers

**Best practices from:**
- Go slog: Simple API, structured by default
- Rust tracing: Compile-time optimization, span-based
- JS pino: Async buffer, SIMD JSON (inspiration!)
- Python logging: Handler/Formatter pattern

**Universal pattern:**
```
Logger → Handler(s) → Formatter → Output
```

---

## MVP Scope (see ai/TODO.md)

**Core features:**
1. Structured fields (key-value pairs)
2. JSON + Text formatters
3. Console + File handlers
4. Extends stdlib.logger (wraps it)

**NOT in MVP:**
- Async buffering
- Log rotation
- Observability integrations
- SIMD optimization

---

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

# JSON output: {"level":"INFO","msg":"user login","user_id":123,"ip":"192.168.1.1"}
# Console output: INFO: user login user_id=123 ip=192.168.1.1
```

---

## Next Steps

1. **API Design** - Define Logger, Handler, Formatter interfaces
2. **Minimal JSON encoder** - ~50-100 LOC for logging-specific JSON
3. **Implement MVP** - Logger + JSONHandler + ConsoleHandler + basic fields
4. **Examples** - Show usage patterns
5. **Tests** - Verify structured fields work

---

## Important Context Files

- `ai/STATUS.md` - Current phase and blockers
- `ai/TODO.md` - Full task breakdown
- `ai/DECISIONS.md` - Why we made each choice
- `ai/RESEARCH.md` - All the logger research (Python, Go, Rust, JS)
- `AGENTS.md` - Public project overview

---

## Architecture Notes

**Why extend stdlib vs replace:**
- stdlib has compile-time level filtering (hard to replicate)
- Future stdlib improvements benefit us
- Interop with existing code
- Less maintenance

**Why minimal JSON encoder:**
- Logging only needs encoding (not parsing)
- Can optimize for log-specific patterns: `{"level":"...","msg":"...","field":value}`
- ~50 LOC vs full JSON library
- Can add EmberJson later if needed

**Handler design:**
```mojo
trait Handler:
    fn handle(self, level: Level, msg: String, fields: Dict[String, Any])
    fn set_formatter(self, formatter: Formatter)
```

**Formatter design:**
```mojo
trait Formatter:
    fn format(self, level: Level, msg: String, fields: Dict[String, Any]) -> String
```

---

## Questions to Resolve

1. How to represent structured fields? Dict[String, Any]? Variadic params?
2. Should Logger own handlers or just reference them?
3. Thread safety - does Mojo need mutex for file writes?
4. How to make formatters/handlers extensible (traits vs protocols)?

---

## Mojo Considerations

- Use `@always_inline` for hot paths
- Leverage compile-time parameters where possible
- Zero-cost abstractions (check disassembly)
- SIMD for JSON encoding (future optimization)
- File I/O - use stdlib or raw syscalls?

---

## When You Resume

1. Read `ai/STATUS.md` for current state
2. Check `ai/TODO.md` for next task
3. Reference this file for context
4. Design API or start coding based on current phase
