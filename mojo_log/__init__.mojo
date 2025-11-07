# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""mojo-log: Structured logging for Mojo.

A production-ready logging library with structured fields, multiple handlers,
and flexible formatters.

Example:
    ```mojo
    from mojo_log import Logger, ConsoleHandler, JSONFormatter, LogFields

    var logger = Logger(
        ConsoleHandler(JSONFormatter())
    )

    var fields = LogFields()
    fields.add_int("user_id", 123)
    logger.info("User logged in", fields)
    ```
"""

from .fields import LogFields, LogValue
