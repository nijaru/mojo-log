# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Tests for mojo-log Logger."""

from logger import Level
from testing import assert_equal
from mojo_log import Logger, LogFields
from mojo_log.formatters import TextFormatter, JSONFormatter
from mojo_log.handlers import ConsoleHandler


fn test_logger_basic() raises:
    """Test basic Logger usage."""
    print("\n--- Test: Logger basic usage ---")

    var logger = Logger(ConsoleHandler(
        TextFormatter(),
        min_level=Level.INFO,
    ))

    print("INFO message:")
    logger.info("application started")

    print("\nWARNING message:")
    logger.warning("low memory")

    print("\nERROR message:")
    logger.error("connection failed")

    print("\n✓ Logger basic usage works")


fn test_logger_with_fields() raises:
    """Test Logger with structured fields."""
    print("\n--- Test: Logger with structured fields ---")

    var logger = Logger(ConsoleHandler(
        TextFormatter(),
        min_level=Level.INFO,
    ))

    var fields = LogFields()
    fields.add_int("user_id", 12345)
    fields.add_string("ip", "192.168.1.1")
    fields.add_bool("authenticated", True)

    print("Expected: INFO: user login user_id=12345 ip=192.168.1.1 authenticated=true")
    print("Actual:")
    logger.info("user login", fields)

    print("\n✓ Logger with fields works")


fn test_logger_json_formatter() raises:
    """Test Logger with JSON formatter."""
    print("\n--- Test: Logger with JSON formatter ---")

    var logger = Logger(ConsoleHandler(
        JSONFormatter(),
        min_level=Level.INFO,
    ))

    var fields = LogFields()
    fields.add_int("request_id", 789)
    fields.add_string("method", "POST")
    fields.add_float("duration_ms", 42.5)

    print('Expected: {"level":"INFO","msg":"API request",...}')
    print("Actual:")
    logger.info("API request", fields)

    print("\n✓ Logger with JSON formatter works")


fn test_logger_all_levels() raises:
    """Test all Logger level methods."""
    print("\n--- Test: Logger all levels ---")

    var logger = Logger(ConsoleHandler(
        TextFormatter(),
        min_level=Level.TRACE,
    ))

    var fields = LogFields()

    print("TRACE:")
    logger.trace("trace message", fields)

    print("DEBUG:")
    logger.debug("debug message", fields)

    print("INFO:")
    logger.info("info message", fields)

    print("WARNING:")
    logger.warning("warning message", fields)

    print("ERROR:")
    logger.error("error message", fields)

    print("CRITICAL:")
    logger.critical("critical message", fields)

    print("\n✓ Logger all levels work")


fn test_logger_set_level() raises:
    """Test Logger.set_level()."""
    print("\n--- Test: Logger set_level ---")

    var logger = Logger(ConsoleHandler(
        TextFormatter(),
        min_level=Level.INFO,
    ))

    # DEBUG is filtered (below INFO)
    print("Before set_level(DEBUG) - DEBUG should be filtered:")
    logger.debug("debug message 1")

    # Change to DEBUG level
    logger.set_level(Level.DEBUG)

    # Now DEBUG should appear
    print("\nAfter set_level(DEBUG) - DEBUG should appear:")
    logger.debug("debug message 2")

    print("\n✓ Logger set_level works")


fn test_logger_without_fields() raises:
    """Test Logger methods without fields argument."""
    print("\n--- Test: Logger without fields ---")

    var logger = Logger(ConsoleHandler(
        TextFormatter(),
        min_level=Level.INFO,
    ))

    print("INFO without fields:")
    logger.info("simple message")

    print("\nERROR without fields:")
    logger.error("error occurred")

    print("\n✓ Logger without fields works")


fn main() raises:
    print("\n=== Testing Logger ===")

    test_logger_basic()
    test_logger_with_fields()
    test_logger_json_formatter()
    test_logger_all_levels()
    test_logger_set_level()
    test_logger_without_fields()

    print("\n✅ All Logger tests passed!\n")
