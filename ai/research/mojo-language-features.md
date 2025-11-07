# Mojo Language Features Research

**Date:** 2025-11-07
**Purpose:** Understanding Mojo's capabilities for building mojo-log

---

## Traits System

Mojo has a robust trait system similar to Rust/Swift:

- **Definition:** `trait TraitName:` defines required methods
- **Implementation:** `struct MyStruct(TraitName):` declares conformance
- **Composition:** `trait Combined(Trait1, Trait2):` or `alias Combined = Trait1 & Trait2`
- **Default implementations:** Traits can provide default method implementations
- **Conditional conformances:** Methods can have stricter trait requirements than the struct itself

### Relevant Traits for Logging

| Trait | Purpose | Key Methods |
|-------|---------|-------------|
| `Writable` | Types that can be written to a Writer | `write_to(mut writer: Writer)` |
| `Writer` | Output destinations (files, buffers) | `write_bytes(bytes: Span[Byte])`, `write(*args: *Ts)` |
| `Copyable` | Types that can be copied | `__copyinit__()` |
| `Movable` | Types with move semantics | `__moveinit__()` |
| `Stringable` | Types convertible to String | `__str__() -> String` |

---

## Type System

### No Generic `Any` Type
- Mojo is statically typed
- No Python-style `Any` type
- Must use specific types or `Variant` for heterogeneous data

### Variant (Sum Type)
```mojo
alias IntOrString = Variant[Int, String]

var value = IntOrString(42)
if value.isa[Int]():
    print(value[Int])  # Access with [T] syntax
```

**Methods:**
- `isa[T]()` - Check current type
- `[T]` - Access value (runtime check)
- `unsafe_get[T]()` - Access without check
- `take[T]()` - Take ownership
- `replace[T]()` - Replace and return old value

### Dict (Type-Safe Dictionary)
```mojo
var d = Dict[String, Int]()
d["key"] = 42
```

- **Compile-time type checking** for keys and values
- No mixed-type dicts without Variant

---

## File I/O

### FileDescriptor
```mojo
@register_passable(trivial)
struct FileDescriptor:
    var value: Int  # File descriptor number
```

**Standard descriptors:**
- `FileDescriptor(1)` - stdout
- `FileDescriptor(2)` - stderr

**Methods:**
- `write(*args: *Ts)` - Write variadic writable arguments
- `write_bytes(bytes: Span[UInt8])` - Write raw bytes

### Context Management
```mojo
with open("file.txt", "w") as f:
    f.write("hello")
# File automatically closed
```

---

## stdlib.logger

### Logger Struct
```mojo
struct Logger[level: Level = Level._from_str(env_get_string["LOGGING_LEVEL", "NOTSET"]())]:
    fn __init__(out self,
                fd: FileDescriptor = FileDescriptor(1),
                *,
                prefix: String = "",
                source_location: Bool = False)
```

**Features:**
- **Compile-time level filtering** via `level` parameter
- Outputs to `FileDescriptor` (configurable)
- Optional prefix for all messages
- Optional source location (file:line) tracking

### Logging Levels
```mojo
alias NOTSET   = Level(0)
alias TRACE    = Level(10)
alias DEBUG    = Level(20)
alias INFO     = Level(30)
alias WARNING  = Level(40)
alias ERROR    = Level(50)
alias CRITICAL = Level(60)
```

**Methods:**
- `logger.trace(*values)` - Trace level
- `logger.debug(*values)` - Debug level
- `logger.info(*values)` - Info level
- `logger.warning(*values)` - Warning level
- `logger.error(*values)` - Error level
- `logger.critical(*values)` - Critical level (aborts execution)

**All methods accept:**
- Variadic `*Ts: Writable` arguments
- `sep: StringSlice` - Separator between values (default: " ")
- `end: StringSlice` - End-of-line string (default: "\n")
- `location: Optional[_SourceLocation]` - Override source location

---

## Concurrency & Thread Safety

### Atomic Operations
```mojo
from os.atomic import Atomic, Consistency, fence

var counter = Atomic[DType.uint64](0)
counter.fetch_add(1)
var value = counter.load[ordering=Consistency.ACQUIRE]()
```

**Available operations:**
- `load()`, `store()` - Read/write with memory ordering
- `fetch_add()`, `fetch_sub()` - Atomic increment/decrement
- `fence()` - Memory barrier

### Memory Ordering
```mojo
alias RELAXED   = Consistency(0)
alias ACQUIRE   = Consistency(2)
alias RELEASE   = Consistency(3)
alias ACQ_REL   = Consistency(4)
alias SEQ_CST   = Consistency(6)  # Default
```

### Synchronization Primitives
- ✅ GPU barriers: `barrier()`, `syncwarp()`, `named_barrier()`
- ❌ **NO CPU mutex/lock in stdlib** (as of research date)
- ❌ **NO RwLock, Condvar, or similar**

**Implication:** Thread-safe logging requires:
1. External synchronization library
2. User-managed locks
3. Single-threaded usage
4. Atomic operations only (limited)

---

## Variadic Parameters

### Basic Variadic
```mojo
fn log(*values: String):
    for value in values:
        print(value)
```

### Generic Variadic
```mojo
fn log[*Ts: Writable](*args: *Ts):
    @parameter
    for i in range(args.__len__()):
        args[i].write_to(writer)
```

---

## Writer/Writable Pattern

This is Mojo's idiom for formatting and output:

### Writer Trait
```mojo
trait Writer:
    fn write_bytes(mut self, bytes: Span[Byte, _])
    fn write[*Ts: Writable](mut self, *args: *Ts)
```

### Writable Trait
```mojo
trait Writable:
    fn write_to[W: Writer](self, mut writer: W)
```

### Example Usage
```mojo
@value
struct Point(Writable):
    var x: Int
    var y: Int

    fn write_to[W: Writer](self, mut writer: W):
        writer.write("Point(", self.x, ", ", self.y, ")")

var p = Point(1, 2)
print(p)  # Output: Point(1, 2)
```

---

## Key Takeaways for mojo-log

1. **Use Variant for structured fields** - `Variant[Int, Float64, String, Bool]`
2. **Define Handler/Formatter as traits** - Follow Writer/Writable pattern
3. **Wrap stdlib.logger, don't replace** - Use its compile-time filtering
4. **Thread safety is NOT in MVP** - Document as future work
5. **Use FileDescriptor for output** - Supports files, stdout, stderr
6. **Leverage compile-time parameters** - For performance optimization
