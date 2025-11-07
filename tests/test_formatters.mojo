# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Tests for mojo-log formatters."""

from logger import Level
from testing import assert_equal
from mojo_log import LogFields
from mojo_log.formatters import JSONFormatter, TextFormatter


fn test_json_formatter_basic() raises:
    """Test JSONFormatter with just level and message."""
    var formatter = JSONFormatter()
    var fields = LogFields()
    var result = formatter.format(Level.INFO, "test message", fields)
    assert_equal(result, '{"level":"INFO","msg":"test message"}')
    print("✓ JSONFormatter basic formatting works")


fn test_json_formatter_with_fields() raises:
    """Test JSONFormatter with structured fields."""
    var formatter = JSONFormatter()
    var fields = LogFields()
    fields.add_int("user_id", 123)
    fields.add_string("method", "GET")
    fields.add_float("duration", 0.42)
    fields.add_bool("success", True)

    var result = formatter.format(Level.INFO, "request", fields)
    # Note: Dict iteration order may vary, but all fields should be present
    # We'll just check that the result contains the expected fields
    var has_level = '"level":"INFO"' in result
    var has_msg = '"msg":"request"' in result
    var has_user_id = '"user_id":123' in result
    var has_method = '"method":"GET"' in result
    var has_duration = '"duration":0.42' in result
    var has_success = '"success":true' in result

    if not (has_level and has_msg and has_user_id and has_method and has_duration and has_success):
        raise Error("JSONFormatter missing expected fields")

    print("✓ JSONFormatter with fields works")


fn test_json_formatter_escaping() raises:
    """Test JSONFormatter escapes special characters."""
    var formatter = JSONFormatter()
    var fields = LogFields()
    fields.add_string("text", 'quote" backslash\\ newline\n tab\t return\r')

    var result = formatter.format(Level.INFO, "escape test", fields)
    var has_escaped = '"text":"quote\\" backslash\\\\ newline\\n tab\\t return\\r"' in result

    if not has_escaped:
        raise Error("JSONFormatter escaping failed")

    print("✓ JSONFormatter escaping works")


fn test_json_formatter_empty_fields() raises:
    """Test JSONFormatter with no fields."""
    var formatter = JSONFormatter()
    var fields = LogFields()
    var result = formatter.format(Level.ERROR, "error message", fields)
    assert_equal(result, '{"level":"ERROR","msg":"error message"}')
    print("✓ JSONFormatter with empty fields works")


fn test_text_formatter_basic() raises:
    """Test TextFormatter with just level and message."""
    var formatter = TextFormatter()
    var fields = LogFields()
    var result = formatter.format(Level.INFO, "test message", fields)
    assert_equal(result, "INFO: test message")
    print("✓ TextFormatter basic formatting works")


fn test_text_formatter_with_fields() raises:
    """Test TextFormatter with structured fields."""
    var formatter = TextFormatter()
    var fields = LogFields()
    fields.add_int("user_id", 123)
    fields.add_string("method", "GET")

    var result = formatter.format(Level.INFO, "request", fields)
    var has_prefix = result.startswith("INFO: request ")
    var has_user_id = "user_id=123" in result
    var has_method = "method=GET" in result

    if not (has_prefix and has_user_id and has_method):
        raise Error("TextFormatter missing expected fields")

    print("✓ TextFormatter with fields works")


fn test_text_formatter_string_quoting() raises:
    """Test TextFormatter quotes strings with spaces."""
    var formatter = TextFormatter()
    var fields = LogFields()
    fields.add_string("no_space", "hello")
    fields.add_string("with_space", "hello world")

    var result = formatter.format(Level.INFO, "quote test", fields)
    var has_unquoted = "no_space=hello" in result
    var has_quoted = 'with_space="hello world"' in result

    if not (has_unquoted and has_quoted):
        raise Error("TextFormatter string quoting failed")

    print("✓ TextFormatter string quoting works")


fn test_text_formatter_all_types() raises:
    """Test TextFormatter with all value types."""
    var formatter = TextFormatter()
    var fields = LogFields()
    fields.add_int("count", 42)
    fields.add_float("ratio", 3.14)
    fields.add_string("name", "test")
    fields.add_bool("active", True)
    fields.add_bool("disabled", False)

    var result = formatter.format(Level.DEBUG, "types test", fields)
    var has_int = "count=42" in result
    var has_float = "ratio=3.14" in result
    var has_string = "name=test" in result
    var has_true = "active=true" in result
    var has_false = "disabled=false" in result

    if not (has_int and has_float and has_string and has_true and has_false):
        raise Error("TextFormatter missing some value types")

    print("✓ TextFormatter with all types works")


fn test_text_formatter_empty_fields() raises:
    """Test TextFormatter with no fields."""
    var formatter = TextFormatter()
    var fields = LogFields()
    var result = formatter.format(Level.WARNING, "warning message", fields)
    assert_equal(result, "WARNING: warning message")
    print("✓ TextFormatter with empty fields works")


fn main() raises:
    print("\n=== Testing Formatters ===\n")

    # JSON formatter tests
    test_json_formatter_basic()
    test_json_formatter_with_fields()
    test_json_formatter_escaping()
    test_json_formatter_empty_fields()

    # Text formatter tests
    test_text_formatter_basic()
    test_text_formatter_with_fields()
    test_text_formatter_string_quoting()
    test_text_formatter_all_types()
    test_text_formatter_empty_fields()

    print("\n✅ All formatter tests passed!\n")
