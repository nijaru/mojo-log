# TODO

## MVP (v0.1.0) - ✅ COMPLETE
- [x] Define Logger API
- [x] Define Handler trait/protocol
- [x] Define Formatter trait/protocol
- [x] Implement JSONFormatter (minimal encoder)
- [x] Implement TextFormatter
- [x] Implement ConsoleHandler
- [x] Structured fields support (Variant-based)
- [x] Level filtering per-handler
- [x] Comprehensive tests (28 tests)
- [x] Example usage
- [x] README documentation

**Not included in MVP:**
- [ ] FileHandler (deferred to v0.2)
- [ ] Multiple handlers per logger (deferred to v0.2)
- [ ] Timestamp support (deferred to v0.2)
- [ ] Source location tracking (deferred to v0.2)

## v0.2 - Enhanced Features
- [ ] FileHandler with basic write support
- [ ] File rotation (size-based, time-based)
- [ ] Multiple handlers per logger
- [ ] Timestamp formatting in log output
- [ ] Source location tracking (_SourceLocation integration)
- [ ] Child loggers (contextual binding)
- [ ] Filter support (custom filtering logic)
- [ ] Performance benchmarks vs stdlib
- [ ] Additional field types (List, nested Dict)

## v0.3 - Performance & Scalability
- [ ] Async buffering for handlers
- [ ] Batched writes
- [ ] SIMD-optimized JSON encoding
- [ ] Lock-free concurrent logging (when Mojo supports it)
- [ ] Memory pool for LogFields allocation
- [ ] Structured benchmarks suite

## v1.0 - Production Ready
- [ ] Comprehensive error handling
- [ ] Graceful degradation modes
- [ ] Configuration file support
- [ ] Environment variable configuration
- [ ] Signal handling for level changes
- [ ] Metrics/stats tracking
- [ ] Production hardening

## Future
- [ ] Integration with observability backends (Loki, Prometheus, etc.)
- [ ] Python logging compatibility layer
- [ ] Sampling/rate limiting
- [ ] Dynamic schema validation
- [ ] Log aggregation utilities
- [ ] CLI tools for log analysis
