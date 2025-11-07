# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Handler trait and utilities for mojo-log.

Handlers receive log records and write them to output destinations.
"""

from logger import Level
from .fields import LogFields


# ===----------------------------------------------------------------------=== #
# Handler Trait
# ===----------------------------------------------------------------------=== #

trait Handler:
    """Handles log records and writes them to an output destination.

    Handlers are responsible for:
    - Level filtering (only process logs at or above min_level)
    - Formatting log records (via a Formatter)
    - Writing formatted output to a destination (console, file, etc.)
    """

    fn handle(
        mut self,
        level: Level,
        msg: String,
        fields: LogFields,
    ):
        """Handle a log record.

        Args:
            level: Log severity level
            msg: Log message
            fields: Structured key-value fields
        """
        ...

    fn set_level(mut self, level: Level):
        """Set the minimum level for this handler.

        Only log records at or above this level will be processed.

        Args:
            level: Minimum log level
        """
        ...

    fn flush(mut self):
        """Flush any buffered output.

        Default implementation does nothing. Override if buffering is used.
        """
        pass

    fn close(mut self):
        """Clean up resources.

        Default implementation does nothing. Override if cleanup is needed.
        """
        pass
