#!/usr/bin/env mojo
# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Basic usage example for mojo-log."""

from logger import Level
from mojo_log import Logger, LogFields
from mojo_log.formatters import TextFormatter, JSONFormatter
from mojo_log.handlers import ConsoleHandler


fn example_text_formatter():
    """Example: Logging with TextFormatter."""
    print("\n=== Text Formatter Example ===\n")

    var logger = Logger(ConsoleHandler(
        TextFormatter(),
        min_level=Level.INFO,
    ))

    # Simple messages
    logger.info("Application started")
    logger.warning("Low memory warning")
    logger.error("Connection failed")

    # With structured fields
    var fields = LogFields()
    fields.add_int("user_id", 12345)
    fields.add_string("ip", "192.168.1.1")
    fields.add_bool("authenticated", True)

    logger.info("User logged in", fields)


fn example_json_formatter():
    """Example: Logging with JSONFormatter."""
    print("\n=== JSON Formatter Example ===\n")

    var logger = Logger(ConsoleHandler(
        JSONFormatter(),
        min_level=Level.INFO,
    ))

    # Simple message
    logger.info("API server started")

    # With structured fields
    var fields = LogFields()
    fields.add_string("method", "POST")
    fields.add_string("path", "/api/users")
    fields.add_int("status", 201)
    fields.add_float("duration_ms", 42.5)

    logger.info("API request completed", fields)


fn example_different_levels():
    """Example: Different log levels."""
    print("\n=== Log Levels Example ===\n")

    var logger = Logger(ConsoleHandler(
        TextFormatter(),
        min_level=Level.TRACE,  # Show all levels
    ))

    logger.trace("Entering function")
    logger.debug("Variable x = 42")
    logger.info("Processing request")
    logger.warning("Cache miss")
    logger.error("Failed to connect")
    logger.critical("System shutting down")


fn example_level_filtering():
    """Example: Level filtering."""
    print("\n=== Level Filtering Example ===\n")

    var logger = Logger(ConsoleHandler(
        TextFormatter(),
        min_level=Level.WARNING,  # Only WARNING and above
    ))

    print("With min_level=WARNING (DEBUG and INFO are filtered):")
    logger.debug("Debug message")  # Won't appear
    logger.info("Info message")    # Won't appear
    logger.warning("Warning message")  # Will appear
    logger.error("Error message")      # Will appear


fn example_dynamic_level():
    """Example: Dynamically changing log level."""
    print("\n=== Dynamic Level Change Example ===\n")

    var logger = Logger(ConsoleHandler(
        TextFormatter(),
        min_level=Level.INFO,
    ))

    print("Initially at INFO level:")
    logger.debug("Debug 1")  # Filtered
    logger.info("Info 1")    # Shown

    print("\nChanging to DEBUG level:")
    logger.set_level(Level.DEBUG)

    logger.debug("Debug 2")  # Now shown
    logger.info("Info 2")    # Shown


fn main():
    """Run all examples."""
    print("\n" + "=" * 60)
    print("mojo-log: Basic Usage Examples")
    print("=" * 60)

    example_text_formatter()
    example_json_formatter()
    example_different_levels()
    example_level_filtering()
    example_dynamic_level()

    print("\n" + "=" * 60)
    print("Examples complete!")
    print("=" * 60 + "\n")
