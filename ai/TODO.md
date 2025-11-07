# TODO

## MVP (v0.1)
- [ ] Define Logger API
- [ ] Define Handler trait/protocol
- [ ] Define Formatter trait/protocol
- [ ] Implement JSONFormatter (minimal encoder)
- [ ] Implement TextFormatter
- [ ] Implement ConsoleHandler
- [ ] Implement FileHandler
- [ ] Structured fields support (Dict-based)
- [ ] Basic tests
- [ ] Example usage

## v0.2
- [ ] Child loggers (contextual binding)
- [ ] Filter support
- [ ] Level filtering per-handler
- [ ] Performance benchmarks vs stdlib

## v0.3
- [ ] Async buffering
- [ ] Log rotation
- [ ] SIMD-optimized JSON encoding

## Future
- [ ] Integration with observability backends (Loki, etc.)
- [ ] Python logging compatibility
- [ ] Sampling/rate limiting
