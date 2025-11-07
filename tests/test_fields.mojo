#!/usr/bin/env mojo
# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Tests for LogFields and LogValue types."""

from testing import assert_equal, assert_true, assert_false

from mojo_log.fields import LogFields, LogValue


fn test_log_fields_creation() raises:
    """Test creating an empty LogFields."""
    var fields = LogFields()
    assert_equal(len(fields), 0)
    print("✓ LogFields creation works")


fn test_add_int() raises:
    """Test adding integer fields."""
    var fields = LogFields()
    fields.add_int("user_id", 123)
    fields.add_int("count", 42)

    assert_equal(len(fields), 2)
    assert_true(fields.contains("user_id"))
    assert_true(fields.contains("count"))

    # Verify the value is stored as Int
    var user_id = fields.data["user_id"]
    assert_true(user_id.isa[Int]())
    assert_equal(user_id[Int], 123)

    print("✓ Adding integers works")


fn test_add_float() raises:
    """Test adding floating-point fields."""
    var fields = LogFields()
    fields.add_float("duration_ms", 42.5)
    fields.add_float("rate", 0.95)

    assert_equal(len(fields), 2)
    assert_true(fields.contains("duration_ms"))

    # Verify the value is stored as Float64
    var duration = fields.data["duration_ms"]
    assert_true(duration.isa[Float64]())
    assert_equal(duration[Float64], 42.5)

    print("✓ Adding floats works")


fn test_add_string() raises:
    """Test adding string fields."""
    var fields = LogFields()
    fields.add_string("method", "GET")
    fields.add_string("path", "/api/users")

    assert_equal(len(fields), 2)
    assert_true(fields.contains("method"))

    # Verify the value is stored as String
    var method = fields.data["method"]
    assert_true(method.isa[String]())
    assert_equal(method[String], "GET")

    print("✓ Adding strings works")


fn test_add_bool() raises:
    """Test adding boolean fields."""
    var fields = LogFields()
    fields.add_bool("success", True)
    fields.add_bool("authenticated", False)

    assert_equal(len(fields), 2)
    assert_true(fields.contains("success"))

    # Verify the value is stored as Bool
    var success = fields.data["success"]
    assert_true(success.isa[Bool]())
    assert_equal(success[Bool], True)

    var auth = fields.data["authenticated"]
    assert_equal(auth[Bool], False)

    print("✓ Adding booleans works")


fn test_mixed_fields() raises:
    """Test adding fields of different types."""
    var fields = LogFields()
    fields.add_int("user_id", 123)
    fields.add_string("method", "POST")
    fields.add_float("duration_ms", 15.3)
    fields.add_bool("success", True)

    assert_equal(len(fields), 4)
    assert_true(fields.contains("user_id"))
    assert_true(fields.contains("method"))
    assert_true(fields.contains("duration_ms"))
    assert_true(fields.contains("success"))

    # Verify each type
    assert_true(fields.data["user_id"].isa[Int]())
    assert_true(fields.data["method"].isa[String]())
    assert_true(fields.data["duration_ms"].isa[Float64]())
    assert_true(fields.data["success"].isa[Bool]())

    print("✓ Mixed type fields work")


fn test_field_overwrite() raises:
    """Test that adding a field with same key overwrites the old value."""
    var fields = LogFields()
    fields.add_int("value", 100)
    assert_equal(fields.data["value"][Int], 100)

    # Overwrite with a new value
    fields.add_int("value", 200)
    assert_equal(len(fields), 1)  # Still only one field
    assert_equal(fields.data["value"][Int], 200)

    print("✓ Field overwrite works")


fn test_contains() raises:
    """Test the contains method."""
    var fields = LogFields()
    assert_false(fields.contains("nonexistent"))

    fields.add_string("key", "value")
    assert_true(fields.contains("key"))
    assert_false(fields.contains("other_key"))

    print("✓ Contains check works")


fn main() raises:
    test_log_fields_creation()
    test_add_int()
    test_add_float()
    test_add_string()
    test_add_bool()
    test_mixed_fields()
    test_field_overwrite()
    test_contains()

    print()
    print("✅ All LogFields tests passed!")
