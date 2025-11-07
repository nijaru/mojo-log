# Architecture Decisions

## Name: mojo-log
**Date:** 2025-11-07
**Decision:** Use simple, descriptive name `mojo-log` over clever puns (embr, lumbr)
**Rationale:** Clear purpose, searchable, follows Mojo ecosystem conventions

## License: Apache 2.0
**Date:** 2025-11-07
**Decision:** Apache 2.0 license
**Rationale:** Matches Mojo stdlib and ecosystem standard

## Public Repository
**Date:** 2025-11-07
**Decision:** Start as public repo
**Rationale:** Zero competition in space, early visibility helps attract contributors, Mojo ecosystem needs open libraries

## Extend stdlib.logger, Don't Replace
**Date:** 2025-11-07
**Decision:** Build wrapper around stdlib.logger rather than fork/replace
**Rationale:**
- stdlib already has compile-time level filtering
- Future stdlib improvements benefit us
- Interop with other code using stdlib
- Less maintenance burden

## Minimal JSON Encoder vs EmberJson Dependency
**Date:** 2025-11-07
**Decision:** Write minimal JSON encoder for logging, don't depend on EmberJson
**Rationale:**
- Logging only needs encoding (not parsing)
- Can optimize for logging-specific patterns
- Avoid dependency for MVP
- ~50-100 LOC for basic encoder
- Can integrate EmberJson later if needed

## Handler/Formatter Architecture
**Date:** 2025-11-07
**Decision:** Use Handler/Formatter pattern (Python logging, Go slog style)
**Rationale:**
- Proven pattern across languages
- Separation of concerns (where to log vs how to format)
- Extensible (users can write custom handlers/formatters)

## API Style: Simple over Verbose
**Date:** 2025-11-07
**Decision:** Use `Logger` not `StructuredLogger`, simple function names
**Rationale:** Matches Go slog, Rust tracing - simplicity wins

## Structured Fields: Variant-Based
**Date:** 2025-11-07
**Decision:** Use `Variant[Int, Float64, String, Bool]` for log field values
**Rationale:**
- Mojo has no generic `Any` type
- Variant provides type-safe sum type
- Explicit about supported types
- No trait object limitation
- Can access type information for efficient serialization

**Alternatives considered:**
- Trait-based: Blocked by lack of trait objects
- Always stringify: Loses type information, can't serialize efficiently

## Handler/Formatter Ownership
**Date:** 2025-11-07
**Decision:** Logger owns handlers, handlers own formatters (by value)
**Rationale:**
- Simpler lifecycle management
- No lifetime/reference complexity
- Handlers cleaned up automatically
- Mojo's reference system still evolving
- Can add reference support later if needed

**Trade-off:** Can't share handlers between loggers (acceptable for MVP)

## No Thread Safety in MVP
**Date:** 2025-11-07
**Decision:** Handlers are NOT thread-safe for v0.1
**Rationale:**
- Mojo stdlib lacks CPU mutexes/locks (as of research date)
- Adding custom mutex implementation would expand scope significantly
- Can document limitation and add sync wrappers in future
- Most initial use cases will be single-threaded

**Future work:** Add `SyncHandler` wrapper when stdlib provides synchronization primitives

## Per-Handler Level Filtering
**Date:** 2025-11-07
**Decision:** Support both global logger level AND per-handler level filtering
**Rationale:**
- Common pattern: debug to file, warnings to console
- Proven useful in Python logging, Go slog
- Minimal complexity cost
- Provides flexibility without requiring multiple loggers

## Explicit LogFields vs Variadic Kwargs
**Date:** 2025-11-07
**Decision:** Use explicit `LogFields` struct with typed `add_*` methods
**Rationale:**
- Mojo doesn't have Python-style kwargs yet
- Explicit types avoid ambiguity
- Fields can be passed around, composed, reused
- Type-safe at call site

**Future enhancement:** Add convenience syntax when Mojo language supports it

## FileDescriptor for Output
**Date:** 2025-11-07
**Decision:** Use Mojo's `FileDescriptor` struct for all file-based output
**Rationale:**
- Standard Mojo type for file I/O
- Supports stdout, stderr, and regular files
- Implements `Writer` trait (fits Mojo idiom)
- Simple and efficient

## No Global Logger Instance
**Date:** 2025-11-07
**Decision:** No singleton global logger (unlike Python's `logging` module)
**Rationale:**
- Explicit > implicit (Mojo philosophy)
- Easier testing (dependency injection)
- No global state complexity
- Can add convenience wrapper later if community wants it

**Pattern:** Pass logger as parameter or store in application context

## Minimal JSON Encoder Strategy
**Date:** 2025-11-07
**Decision:** Implement basic JSON escaping only (quotes, newlines, backslashes)
**Rationale:**
- Logging doesn't need full JSON spec compliance
- Simple escaping covers 99% of use cases
- Fast implementation (~20-30 LOC)
- Can enhance later if needed

**Trade-off:** Won't handle all Unicode edge cases (acceptable for MVP)
