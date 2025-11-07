# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Text formatter for mojo-log."""

from logger import Level
from ..fields import LogFields, LogValue
from ..formatter import Formatter


# ===----------------------------------------------------------------------=== #
# Text Utilities
# ===----------------------------------------------------------------------=== #

fn format_log_value_text(value: LogValue) -> String:
    """Format a LogValue as text.

    Args:
        value: LogValue to format

    Returns:
        Text representation of the value
    """
    if value.isa[Int]():
        return String(value[Int])
    elif value.isa[Float64]():
        return String(value[Float64])
    elif value.isa[String]():
        var s = value[String]
        # Quote strings if they contain spaces
        if " " in s:
            return '"' + s + '"'
        return s
    elif value.isa[Bool]():
        return "true" if value[Bool] else "false"
    else:
        return "null"


# ===----------------------------------------------------------------------=== #
# TextFormatter
# ===----------------------------------------------------------------------=== #

struct TextFormatter(Formatter, Movable):
    """Formats log records as human-readable text.

    Produces key=value formatted output suitable for console logging.

    Example output:
        INFO: user login user_id=123 method=GET
    """

    fn __init__(out self):
        """Initialize the text formatter."""
        pass

    fn format(
        self,
        level: Level,
        msg: String,
        fields: LogFields,
    ) -> String:
        """Format a log record as text.

        Args:
            level: Log severity level
            msg: Log message
            fields: Structured key-value fields

        Returns:
            Text-formatted log record
        """
        var result = String(level) + ": " + msg

        # Add structured fields as key=value pairs
        if len(fields) > 0:
            result += " "
            var first = True
            for item in fields.data.items():
                if not first:
                    result += " "
                result += item.key + "=" + format_log_value_text(item.value)
                first = False

        return result
