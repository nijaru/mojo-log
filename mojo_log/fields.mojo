# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Structured logging fields for mojo-log.

This module provides types and utilities for storing structured key-value
fields in log records. Fields are type-safe using Mojo's Variant type.

Example:
    ```mojo
    from mojo_log.fields import LogFields

    var fields = LogFields()
    fields.add_int("user_id", 123)
    fields.add_string("method", "GET")
    fields.add_float("duration_ms", 42.5)
    fields.add_bool("success", True)
    ```
"""

from collections.dict import Dict
from utils.variant import Variant


# ===----------------------------------------------------------------------=== #
# LogValue
# ===----------------------------------------------------------------------=== #

alias LogValue = Variant[Int, Float64, String, Bool]
"""Type alias for log field values.

Supports the following types:
- Int: Integer values (user IDs, counts, status codes)
- Float64: Floating-point values (durations, rates, percentages)
- String: Text values (names, messages, IDs)
- Bool: Boolean flags (success, enabled, authenticated)
"""


# ===----------------------------------------------------------------------=== #
# LogFields
# ===----------------------------------------------------------------------=== #

struct LogFields(Sized):
    """Container for structured log fields.

    Stores key-value pairs where keys are strings and values can be
    Int, Float64, String, or Bool. Provides type-safe methods for adding
    fields of each supported type.
    """

    var data: Dict[String, LogValue]
    """Internal storage for field data."""

    fn __init__(out self):
        """Initialize an empty LogFields container."""
        self.data = Dict[String, LogValue]()

    fn add_int(mut self, key: String, value: Int):
        """Add an integer field.

        Args:
            key: Field name
            value: Integer value
        """
        self.data[key] = LogValue(value)

    fn add_float(mut self, key: String, value: Float64):
        """Add a floating-point field.

        Args:
            key: Field name
            value: Float64 value
        """
        self.data[key] = LogValue(value)

    fn add_string(mut self, key: String, value: String):
        """Add a string field.

        Args:
            key: Field name
            value: String value
        """
        self.data[key] = LogValue(value)

    fn add_bool(mut self, key: String, value: Bool):
        """Add a boolean field.

        Args:
            key: Field name
            value: Bool value
        """
        self.data[key] = LogValue(value)

    fn __len__(self) -> Int:
        """Return the number of fields.

        Required by the Sized trait.
        """
        return len(self.data)

    fn contains(self, key: String) -> Bool:
        """Check if a field with the given key exists.

        Args:
            key: Field name to check

        Returns:
            True if the field exists, False otherwise
        """
        return key in self.data
