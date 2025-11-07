# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""File handler for mojo-log."""

from io.file import open, FileHandle
from logger import Level
from ..fields import LogFields
from ..formatter import Formatter
from ..handler import Handler


# ===----------------------------------------------------------------------=== #
# FileHandler
# ===----------------------------------------------------------------------=== #

struct FileHandler[FormatterType: Formatter & Movable](Handler, Movable):
    """Writes log records to a file.

    Formats log records using the provided formatter and writes them to
    a file specified by path. The file is opened in append mode by default.

    Parameters:
        FormatterType: The type of formatter to use

    Example:
        ```mojo
        from mojo_log.formatters import JSONFormatter
        var handler = FileHandler[JSONFormatter](
            "app.log",
            JSONFormatter(),
            min_level=Level.INFO
        )
        ```
    """

    var formatter: FormatterType
    var min_level: Level
    var file: FileHandle

    fn __init__(
        out self,
        path: String,
        var formatter: FormatterType,
        *,
        min_level: Level = Level.INFO,
        mode: String = "a",
    ) raises:
        """Initialize the file handler.

        Args:
            path: Path to the log file
            formatter: Formatter to use for formatting log records
            min_level: Minimum level to log (default: Level.INFO)
            mode: File open mode - "a" for append, "w" for write (default: "a")

        Raises:
            If the file cannot be opened
        """
        self.formatter = formatter^
        self.min_level = min_level
        self.file = open(path, mode)

    fn handle(
        mut self,
        level: Level,
        msg: String,
        fields: LogFields,
    ):
        """Handle a log record by formatting and writing to file.

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
        self.file.write(formatted, "\n")

    fn set_level(mut self, level: Level):
        """Set the minimum level for this handler.

        Args:
            level: Minimum log level
        """
        self.min_level = level

    fn flush(mut self):
        """Flush buffered output to disk.

        Note: FileHandle writes are typically unbuffered, but this
        can be used to ensure data is written to disk.
        """
        # FileHandle doesn't have explicit flush, writes go through immediately
        pass

    fn close(mut self):
        """Close the log file.

        This is called automatically when the handler is destroyed.
        """
        try:
            self.file.close()
        except:
            # Ignore errors on close
            pass
