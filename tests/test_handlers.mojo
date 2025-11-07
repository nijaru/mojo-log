# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Tests for mojo-log handlers."""

from logger import Level
from testing import assert_equal
from mojo_log import LogFields
from mojo_log.formatters import TextFormatter, JSONFormatter
from mojo_log.handlers import ConsoleHandler


fn test_console_handler_level_filtering() raises:
    """Test ConsoleHandler filters by level."""
    print("\n--- Test: ConsoleHandler level filtering ---")

    var handler = ConsoleHandler[TextFormatter](
        TextFormatter(),
        min_level=Level.INFO,
    )

    var fields = LogFields()
    fields.add_string("test", "value")

    # This should be filtered out (DEBUG < INFO)
    print("DEBUG message (should NOT appear):")
    handler.handle(Level.DEBUG, "debug message", fields)

    # These should appear
    print("\nINFO message (should appear):")
    handler.handle(Level.INFO, "info message", fields)

    print("\nERROR message (should appear):")
    handler.handle(Level.ERROR, "error message", fields)

    print("\n✓ ConsoleHandler level filtering works")


fn test_console_handler_set_level() raises:
    """Test ConsoleHandler.set_level()."""
    print("\n--- Test: ConsoleHandler set_level ---")

    var handler = ConsoleHandler[TextFormatter](
        TextFormatter(),
        min_level=Level.INFO,
    )

    var fields = LogFields()

    # Initially set to INFO, so DEBUG is filtered
    print("Before set_level(DEBUG):")
    handler.handle(Level.DEBUG, "debug message 1", fields)

    # Change to DEBUG level
    handler.set_level(Level.DEBUG)

    # Now DEBUG should appear
    print("\nAfter set_level(DEBUG):")
    handler.handle(Level.DEBUG, "debug message 2", fields)

    print("\n✓ ConsoleHandler set_level works")


fn test_console_handler_text_formatter() raises:
    """Test ConsoleHandler with TextFormatter."""
    print("\n--- Test: ConsoleHandler with TextFormatter ---")

    var handler = ConsoleHandler[TextFormatter](
        TextFormatter(),
        min_level=Level.INFO,
    )

    var fields = LogFields()
    fields.add_int("user_id", 123)
    fields.add_string("method", "POST")
    fields.add_float("duration", 0.42)

    print("Expected format: INFO: user login user_id=123 method=POST duration=0.42")
    print("Actual output:")
    handler.handle(Level.INFO, "user login", fields)

    print("\n✓ ConsoleHandler with TextFormatter works")


fn test_console_handler_json_formatter() raises:
    """Test ConsoleHandler with JSONFormatter."""
    print("\n--- Test: ConsoleHandler with JSONFormatter ---")

    var handler = ConsoleHandler[JSONFormatter](
        JSONFormatter(),
        min_level=Level.INFO,
    )

    var fields = LogFields()
    fields.add_int("user_id", 123)
    fields.add_string("action", "login")

    print('Expected format: {"level":"INFO","msg":"user action",...}')
    print("Actual output:")
    handler.handle(Level.INFO, "user action", fields)

    print("\n✓ ConsoleHandler with JSONFormatter works")


fn test_console_handler_stderr() raises:
    """Test ConsoleHandler writing to stderr."""
    print("\n--- Test: ConsoleHandler with stderr ---")

    var handler = ConsoleHandler[TextFormatter](
        TextFormatter(),
        min_level=Level.ERROR,
        use_stderr=True,
    )

    var fields = LogFields()
    fields.add_string("error", "connection refused")

    print("Next line should go to stderr:")
    handler.handle(Level.ERROR, "connection error", fields)

    print("\n✓ ConsoleHandler with stderr works")


fn main() raises:
    print("\n=== Testing Handlers ===")

    test_console_handler_level_filtering()
    test_console_handler_set_level()
    test_console_handler_text_formatter()
    test_console_handler_json_formatter()
    test_console_handler_stderr()

    print("\n✅ All handler tests passed!\n")
