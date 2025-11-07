# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Console handler for mojo-log."""

from io import FileDescriptor
from logger import Level
from ..fields import LogFields
from ..formatter import Formatter
from ..handler import Handler


# ===----------------------------------------------------------------------=== #
# ConsoleHandler
# ===----------------------------------------------------------------------=== #

struct ConsoleHandler[FormatterType: Formatter & Movable](Handler, Movable):
    """Writes log records to stdout or stderr.

    Formats log records using the provided formatter and writes them to
    either stdout (default) or stderr.

    Parameters:
        FormatterType: The type of formatter to use

    Example:
        ```mojo
        from mojo_log.formatters import TextFormatter
        var handler = ConsoleHandler[TextFormatter](
            TextFormatter(),
            min_level=Level.INFO
        )
        ```
    """

    var formatter: FormatterType
    var min_level: Level
    var fd: FileDescriptor

    fn __init__(
        out self,
        var formatter: FormatterType,
        *,
        min_level: Level = Level.INFO,
        use_stderr: Bool = False,
    ):
        """Initialize the console handler.

        Args:
            formatter: Formatter to use for formatting log records
            min_level: Minimum level to log (default: Level.INFO)
            use_stderr: Write to stderr instead of stdout (default: False)
        """
        self.formatter = formatter^
        self.min_level = min_level
        # FileDescriptor: 1 = stdout, 2 = stderr
        self.fd = FileDescriptor(2 if use_stderr else 1)

    fn handle(
        mut self,
        level: Level,
        msg: String,
        fields: LogFields,
    ):
        """Handle a log record by formatting and writing to console.

        Args:
            level: Log severity level
            msg: Log message
            fields: Structured key-value fields
        """
        # Level filtering
        if level._value < self.min_level._value:
            return

        # Format and write
        var formatted = self.formatter.format(level, msg, fields)
        self.fd.write(formatted, "\n")

    fn set_level(mut self, level: Level):
        """Set the minimum level for this handler.

        Args:
            level: Minimum log level
        """
        self.min_level = level

    fn flush(mut self):
        """Flush any buffered output.

        FileDescriptor writes are unbuffered, so this is a no-op.
        """
        pass

    fn close(mut self):
        """Clean up resources.

        No cleanup needed for console output.
        """
        pass
