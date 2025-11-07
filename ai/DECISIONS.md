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
