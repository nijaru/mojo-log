# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Formatter trait and utilities for mojo-log.

Formatters convert log records into formatted strings (JSON, text, etc.).
"""

from logger import Level
from .fields import LogFields


# ===----------------------------------------------------------------------=== #
# Formatter Trait
# ===----------------------------------------------------------------------=== #

trait Formatter:
    """Formats log records into strings.

    Implementations determine how log records are formatted for output,
    such as JSON, human-readable text, or custom formats.
    """

    fn format(
        self,
        level: Level,
        msg: String,
        fields: LogFields,
    ) -> String:
        """Format a log record into a string.

        Args:
            level: Log severity level
            msg: Log message
            fields: Structured key-value fields

        Returns:
            Formatted log record as a string
        """
        ...
