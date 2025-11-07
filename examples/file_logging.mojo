#!/usr/bin/env mojo
# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""File logging example for mojo-log."""

from logger import Level
from mojo_log import Logger, LogFields
from mojo_log.formatters import TextFormatter, JSONFormatter
from mojo_log.handlers import FileHandler
from pathlib import Path


fn example_basic_file_logging() raises:
    """Example: Basic file logging."""
    print("\n=== Basic File Logging ===\n")

    var log_file = "app.log"

    # Create logger with file handler
    var logger = Logger(FileHandler(
        log_file,
        TextFormatter(),
        min_level=Level.INFO,
    ))

    # Log some messages
    logger.info("Application started")
    logger.warning("Low memory")
    logger.error("Connection failed")

    # Add structured fields
    var fields = LogFields()
    fields.add_int("user_id", 123)
    fields.add_string("action", "login")
    logger.info("User action", fields)

    # Close to flush
    logger.close()

    # Read and display
    var path = Path(log_file)
    var content = path.read_text()
    print("Log file content:")
    print(content)


fn example_json_file_logging() raises:
    """Example: JSON file logging."""
    print("\n=== JSON File Logging ===\n")

    var log_file = "app.json.log"

    # Create logger with JSON formatter
    var logger = Logger(FileHandler(
        log_file,
        JSONFormatter(),
        min_level=Level.DEBUG,
    ))

    # Log structured data
    var fields = LogFields()
    fields.add_string("method", "POST")
    fields.add_string("path", "/api/users")
    fields.add_int("status", 201)
    fields.add_float("duration_ms", 42.5)
    fields.add_bool("success", True)

    logger.info("API request", fields)

    logger.close()

    # Read and display
    var path = Path(log_file)
    var content = path.read_text()
    print("JSON log file content:")
    print(content)


fn example_append_mode() raises:
    """Example: Append mode for persistent logs."""
    print("\n=== Append Mode ===\n")

    var log_file = "persistent.log"

    # First run - write initial logs
    print("First run:")
    var logger1 = Logger(FileHandler(
        log_file,
        TextFormatter(),
        mode="w",  # Write mode (overwrites)
    ))
    logger1.info("Session 1 started")
    logger1.close()

    # Second run - append more logs
    print("Second run:")
    var logger2 = Logger(FileHandler(
        log_file,
        TextFormatter(),
        mode="a",  # Append mode (default)
    ))
    logger2.info("Session 2 started")
    logger2.close()

    # Third run - append more logs
    print("Third run:")
    var logger3 = Logger(FileHandler(
        log_file,
        TextFormatter(),
        mode="a",
    ))
    logger3.info("Session 3 started")
    logger3.close()

    # Read and display all sessions
    var path = Path(log_file)
    var content = path.read_text()
    print("\nPersistent log file (all sessions):")
    print(content)


fn example_level_filtering() raises:
    """Example: Level filtering for production logs."""
    print("\n=== Level Filtering ===\n")

    var log_file = "production.log"

    # Only log WARNING and above for production
    var logger = Logger(FileHandler(
        log_file,
        TextFormatter(),
        min_level=Level.WARNING,
    ))

    # These are filtered out
    logger.debug("Debug info")
    logger.info("Info message")

    # These are logged
    logger.warning("Low disk space")
    logger.error("Database connection lost")
    logger.critical("System failure")

    logger.close()

    # Read and display
    var path = Path(log_file)
    var content = path.read_text()
    print("Production log (WARNING and above only):")
    print(content)


fn main() raises:
    print("\n" + "=" * 60)
    print("mojo-log: File Logging Examples")
    print("=" * 60)

    example_basic_file_logging()
    example_json_file_logging()
    example_append_mode()
    example_level_filtering()

    print("\n" + "=" * 60)
    print("Examples complete!")
    print("=" * 60 + "\n")
