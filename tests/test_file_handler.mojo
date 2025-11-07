# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Tests for FileHandler."""

from logger import Level
from testing import assert_true
from mojo_log import LogFields
from mojo_log.formatters import TextFormatter, JSONFormatter
from mojo_log.handlers import FileHandler
from pathlib import Path
from os import remove


fn test_file_handler_basic() raises:
    """Test basic FileHandler usage."""
    print("\n--- Test: FileHandler basic ---")

    var test_file = "test_basic.log"

    # Create handler and write logs
    var handler = FileHandler[TextFormatter](
        test_file,
        TextFormatter(),
        min_level=Level.INFO,
    )

    var fields = LogFields()
    fields.add_string("test", "basic")

    handler.handle(Level.INFO, "test message", fields)
    handler.handle(Level.ERROR, "error message", fields)
    handler.close()

    # Read file and verify
    var path = Path(test_file)
    var content = path.read_text()

    assert_true("INFO: test message" in content, "Should contain INFO message")
    assert_true("ERROR: error message" in content, "Should contain ERROR message")
    assert_true("test=basic" in content, "Should contain fields")

    print("File content:")
    print(content)

    # Cleanup
    remove(test_file)

    print("✓ FileHandler basic works")


fn test_file_handler_json() raises:
    """Test FileHandler with JSON formatter."""
    print("\n--- Test: FileHandler with JSON ---")

    var test_file = "test_json.log"

    var handler = FileHandler[JSONFormatter](
        test_file,
        JSONFormatter(),
        min_level=Level.INFO,
    )

    var fields = LogFields()
    fields.add_int("user_id", 123)
    fields.add_string("action", "login")

    handler.handle(Level.INFO, "user action", fields)
    handler.close()

    # Read and verify
    var path = Path(test_file)
    var content = path.read_text()

    assert_true('"level":"INFO"' in content, "Should contain level")
    assert_true('"msg":"user action"' in content, "Should contain message")
    assert_true('"user_id":123' in content, "Should contain user_id")
    assert_true('"action":"login"' in content, "Should contain action")

    print("JSON output:")
    print(content)

    remove(test_file)

    print("✓ FileHandler with JSON works")


fn test_file_handler_level_filtering() raises:
    """Test FileHandler level filtering."""
    print("\n--- Test: FileHandler level filtering ---")

    var test_file = "test_filtering.log"

    var handler = FileHandler[TextFormatter](
        test_file,
        TextFormatter(),
        min_level=Level.WARNING,  # Only WARNING and above
    )

    var fields = LogFields()

    handler.handle(Level.DEBUG, "debug message", fields)   # Filtered
    handler.handle(Level.INFO, "info message", fields)     # Filtered
    handler.handle(Level.WARNING, "warning message", fields)  # Shown
    handler.handle(Level.ERROR, "error message", fields)      # Shown
    handler.close()

    # Read and verify
    var path = Path(test_file)
    var content = path.read_text()

    # Should NOT contain filtered messages
    assert_true("DEBUG" not in content, "Should filter DEBUG")
    assert_true("info message" not in content, "Should filter INFO")

    # Should contain WARNING and ERROR
    assert_true("WARNING: warning message" in content, "Should contain WARNING")
    assert_true("ERROR: error message" in content, "Should contain ERROR")

    print("Filtered output:")
    print(content)

    remove(test_file)

    print("✓ FileHandler level filtering works")


fn test_file_handler_append_mode() raises:
    """Test FileHandler append mode."""
    print("\n--- Test: FileHandler append mode ---")

    var test_file = "test_append.log"

    # Write first message
    var handler1 = FileHandler[TextFormatter](
        test_file,
        TextFormatter(),
        mode="w",  # Write mode (overwrites)
    )
    var fields = LogFields()
    handler1.handle(Level.INFO, "first message", fields)
    handler1.close()

    # Append second message
    var handler2 = FileHandler[TextFormatter](
        test_file,
        TextFormatter(),
        mode="a",  # Append mode
    )
    handler2.handle(Level.INFO, "second message", fields)
    handler2.close()

    # Read and verify both messages exist
    var path = Path(test_file)
    var content = path.read_text()

    assert_true("first message" in content, "Should contain first message")
    assert_true("second message" in content, "Should contain second message")

    print("Appended content:")
    print(content)

    remove(test_file)

    print("✓ FileHandler append mode works")


fn test_file_handler_set_level() raises:
    """Test FileHandler.set_level()."""
    print("\n--- Test: FileHandler set_level ---")

    var test_file = "test_set_level.log"

    var handler = FileHandler[TextFormatter](
        test_file,
        TextFormatter(),
        min_level=Level.INFO,
    )

    var fields = LogFields()

    # DEBUG is filtered at INFO level
    handler.handle(Level.DEBUG, "debug 1", fields)

    # Change to DEBUG level
    handler.set_level(Level.DEBUG)

    # Now DEBUG should be written
    handler.handle(Level.DEBUG, "debug 2", fields)
    handler.close()

    # Read and verify
    var path = Path(test_file)
    var content = path.read_text()

    assert_true("debug 1" not in content, "debug 1 should be filtered")
    assert_true("DEBUG: debug 2" in content, "debug 2 should be written")

    print("Dynamic level change output:")
    print(content)

    remove(test_file)

    print("✓ FileHandler set_level works")


fn main() raises:
    print("\n=== Testing FileHandler ===")

    test_file_handler_basic()
    test_file_handler_json()
    test_file_handler_level_filtering()
    test_file_handler_append_mode()
    test_file_handler_set_level()

    print("\n✅ All FileHandler tests passed!\n")
