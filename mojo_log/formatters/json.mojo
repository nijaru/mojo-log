# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""JSON formatter for mojo-log."""

from logger import Level
from ..fields import LogFields, LogValue
from ..formatter import Formatter


# ===----------------------------------------------------------------------=== #
# JSON Utilities
# ===----------------------------------------------------------------------=== #

fn escape_json_string(s: String) -> String:
    """Escape a string for JSON output.

    Escapes quotes, backslashes, and common control characters.

    Args:
        s: String to escape

    Returns:
        JSON-escaped string
    """
    var result = String()

    for i in range(len(s)):
        var c = s[i]

        if c == '"':
            result += '\\"'
        elif c == '\\':
            result += '\\\\'
        elif c == '\n':
            result += '\\n'
        elif c == '\r':
            result += '\\r'
        elif c == '\t':
            result += '\\t'
        else:
            result += c

    return result


fn format_log_value_json(value: LogValue) -> String:
    """Format a LogValue as JSON.

    Args:
        value: LogValue to format

    Returns:
        JSON representation of the value
    """
    if value.isa[Int]():
        return String(value[Int])
    elif value.isa[Float64]():
        return String(value[Float64])
    elif value.isa[String]():
        return '"' + escape_json_string(value[String]) + '"'
    elif value.isa[Bool]():
        return "true" if value[Bool] else "false"
    else:
        return "null"


# ===----------------------------------------------------------------------=== #
# JSONFormatter
# ===----------------------------------------------------------------------=== #

struct JSONFormatter(Formatter):
    """Formats log records as JSON.

    Produces compact JSON output suitable for structured logging systems.

    Example output:
        {"level":"INFO","msg":"user login","user_id":123}
    """

    fn __init__(out self):
        """Initialize the JSON formatter."""
        pass

    fn format(
        self,
        level: Level,
        msg: String,
        fields: LogFields,
    ) -> String:
        """Format a log record as JSON.

        Args:
            level: Log severity level
            msg: Log message
            fields: Structured key-value fields

        Returns:
            JSON-formatted log record
        """
        var result = String("{")

        # Add level
        result += '"level":"' + String(level) + '"'

        # Add message
        result += ',"msg":"' + escape_json_string(msg) + '"'

        # Add structured fields
        for item in fields.data.items():
            result += ',"' + escape_json_string(item.key) + '":'
            result += format_log_value_json(item.value)

        result += "}"
        return result
