# Structured Fields Design

**Date:** 2025-11-07
**Status:** Proposed

---

## Problem

How do we represent structured key-value fields in a statically-typed language without a generic `Any` type?

---

## Options Considered

### Option 1: Variant-Based (RECOMMENDED)

Use `Variant` to hold different value types:

```mojo
alias LogValue = Variant[Int, Float64, String, Bool]

struct LogRecord:
    var fields: Dict[String, LogValue]
```

**Pros:**
- ✅ Type-safe at runtime
- ✅ Explicit about supported types
- ✅ No external dependencies
- ✅ Mojo's native type for sum types

**Cons:**
- ❌ Limited to predefined types
- ❌ Slightly verbose to access values

### Option 2: Trait-Based

Define a `LoggableValue` trait:

```mojo
trait LoggableValue:
    fn format(self) -> String

struct LogRecord:
    var fields: Dict[String, LoggableValue]  # Won't work - need trait objects
```

**Problem:** Mojo doesn't have trait objects (dynamic dispatch on traits). Can't store `Dict[String, LoggableValue]`.

### Option 3: Always Stringify

Convert all values to strings immediately:

```mojo
struct LogRecord:
    var fields: Dict[String, String]
```

**Pros:**
- ✅ Simplest implementation
- ✅ No type complexity

**Cons:**
- ❌ Loss of type information
- ❌ Can't serialize to structured formats efficiently
- ❌ No numeric operations (filtering, aggregation)

---

## Decision: Variant-Based Approach

Use `Variant[Int, Float64, String, Bool]` for log field values.

### Type Mapping

| User Type | Stored As | Example |
|-----------|-----------|---------|
| `Int`, `Int32`, `Int64` | `Int` | `user_id=123` |
| `Float32`, `Float64` | `Float64` | `response_time=0.42` |
| `String`, `StringLiteral` | `String` | `method="GET"` |
| `Bool` | `Bool` | `success=True` |

### API Design

```mojo
alias LogValue = Variant[Int, Float64, String, Bool]

struct LogFields:
    """Container for structured log fields."""
    var data: Dict[String, LogValue]

    fn __init__(out self):
        self.data = Dict[String, LogValue]()

    fn add_int(mut self, key: String, value: Int):
        self.data[key] = LogValue(value)

    fn add_float(mut self, key: String, value: Float64):
        self.data[key] = LogValue(value)

    fn add_string(mut self, key: String, value: String):
        self.data[key] = LogValue(value)

    fn add_bool(mut self, key: String, value: Bool):
        self.data[key] = LogValue(value)

    # Generic add method (future enhancement)
    fn add[T: LoggableType](mut self, key: String, value: T):
        # Convert T to appropriate LogValue variant
        ...

# Usage
var fields = LogFields()
fields.add_int("user_id", 123)
fields.add_string("ip", "192.168.1.1")
fields.add_bool("authenticated", True)
```

---

## Alternative API: Variadic Constructor

For ergonomics, support variadic field initialization:

```mojo
# Option A: Tuples (verbose but explicit)
var fields = LogFields(
    ("user_id", 123),
    ("ip", "192.168.1.1"),
    ("authenticated", True)
)

# Option B: Keyword-style (if Mojo supports in future)
var fields = LogFields(
    user_id=123,
    ip="192.168.1.1",
    authenticated=True
)
```

**For MVP:** Start with explicit `add_*` methods. Add convenience APIs later.

---

## Formatters and LogValue

### JSON Formatting

```mojo
fn format_json(value: LogValue) -> String:
    if value.isa[Int]():
        return String(value[Int])
    elif value.isa[Float64]():
        return String(value[Float64])
    elif value.isa[String]():
        return escape_json(value[String])  # Escape quotes, etc.
    elif value.isa[Bool]():
        return "true" if value[Bool] else "false"
    else:
        return "null"
```

### Text Formatting

```mojo
fn format_text(key: String, value: LogValue) -> String:
    if value.isa[String]():
        # Quote strings if they contain spaces
        var s = value[String]
        return key + "=" + ('"' + s + '"' if " " in s else s)
    else:
        # Numbers and bools don't need quotes
        return key + "=" + String(value)
```

---

## Performance Considerations

### Memory Layout

`Variant[Int, Float64, String, Bool]` stores:
- Tag (which type is active)
- Union of all types (sized to largest member)

**Size:** `~max(sizeof(Int), sizeof(Float64), sizeof(String), sizeof(Bool)) + tag`

For MVP, this is acceptable. Future optimization: separate hot/cold paths.

### Optimization Opportunities (Future)

1. **Small Value Optimization:** Pack small values inline
2. **Type-specific Dicts:** `Dict[String, Int]` for known-type fields
3. **Compile-time specialization:** Different code paths per value type

---

## Compatibility with stdlib.logger

stdlib.logger accepts `*Ts: Writable` for messages. We can:

1. Make `LogFields` implement `Writable`
2. Have formatters produce `String` output
3. Pass formatted string to stdlib.logger

```mojo
struct LogFields(Writable):
    var data: Dict[String, LogValue]

    fn write_to[W: Writer](self, mut writer: W):
        # Format fields as key=value pairs
        var first = True
        for item in self.data.items():
            if not first:
                writer.write(" ")
            writer.write(item.key, "=", format_text(item.value))
            first = False

# Usage with stdlib.logger
var logger = Logger()
var fields = LogFields()
fields.add_int("user_id", 123)
logger.info("user login", fields)  # Output: "user login user_id=123"
```

---

## Future Enhancements

### 1. Nested Fields
```mojo
fields.add("request", Dict[String, LogValue]{ "method": "GET", "path": "/api" })
# JSON: {"request": {"method": "GET", "path": "/api"}}
```

### 2. Arrays
```mojo
fields.add("tags", List[String]{"auth", "api"})
# JSON: {"tags": ["auth", "api"]}
```

### 3. Custom Types
```mojo
trait LoggableType:
    fn to_log_value(self) -> LogValue

struct UserID(LoggableType):
    var value: Int
    fn to_log_value(self) -> LogValue:
        return LogValue(self.value)
```

---

## Open Questions

1. **Field name validation?** (e.g., disallow spaces, special chars)
2. **Reserved field names?** (e.g., `level`, `msg`, `timestamp`)
3. **Field ordering?** Dict is unordered - does it matter for logs?
4. **Large string handling?** Should we limit string field size?

**For MVP:** Accept these questions as future work.
