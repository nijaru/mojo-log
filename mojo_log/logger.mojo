# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, nijaru. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Logger struct for mojo-log.

The Logger is the main entry point for structured logging.
"""

from logger import Level
from .fields import LogFields
from .handler import Handler


# ===----------------------------------------------------------------------=== #
# Logger
# ===----------------------------------------------------------------------=== #

struct Logger[HandlerType: Handler & Movable](Movable):
    """Main logging interface with structured field support.

    The Logger provides level-specific methods (debug, info, warning, etc.)
    and passes log records to the configured handler for output.

    Parameters:
        HandlerType: The type of handler to use

    Example:
        ```mojo
        from logger import Level
        from mojo_log import Logger, LogFields
        from mojo_log.formatters import TextFormatter
        from mojo_log.handlers import ConsoleHandler

        var logger = Logger(ConsoleHandler(
            TextFormatter(),
            min_level=Level.INFO
        ))

        var fields = LogFields()
        fields.add_int("user_id", 123)
        logger.info("user logged in", fields)
        ```
    """

    var handler: HandlerType

    fn __init__(out self, var handler: HandlerType):
        """Initialize the logger with a handler.

        Args:
            handler: Handler to process log records
        """
        self.handler = handler^

    fn trace(mut self, msg: String, fields: LogFields = LogFields()):
        """Log a TRACE level message.

        Args:
            msg: Log message
            fields: Structured key-value fields (optional)
        """
        self.handler.handle(Level.TRACE, msg, fields)

    fn debug(mut self, msg: String, fields: LogFields = LogFields()):
        """Log a DEBUG level message.

        Args:
            msg: Log message
            fields: Structured key-value fields (optional)
        """
        self.handler.handle(Level.DEBUG, msg, fields)

    fn info(mut self, msg: String, fields: LogFields = LogFields()):
        """Log an INFO level message.

        Args:
            msg: Log message
            fields: Structured key-value fields (optional)
        """
        self.handler.handle(Level.INFO, msg, fields)

    fn warning(mut self, msg: String, fields: LogFields = LogFields()):
        """Log a WARNING level message.

        Args:
            msg: Log message
            fields: Structured key-value fields (optional)
        """
        self.handler.handle(Level.WARNING, msg, fields)

    fn error(mut self, msg: String, fields: LogFields = LogFields()):
        """Log an ERROR level message.

        Args:
            msg: Log message
            fields: Structured key-value fields (optional)
        """
        self.handler.handle(Level.ERROR, msg, fields)

    fn critical(mut self, msg: String, fields: LogFields = LogFields()):
        """Log a CRITICAL level message.

        Args:
            msg: Log message
            fields: Structured key-value fields (optional)
        """
        self.handler.handle(Level.CRITICAL, msg, fields)

    fn set_level(mut self, level: Level):
        """Set the minimum logging level.

        Args:
            level: Minimum level to log
        """
        self.handler.set_level(level)

    fn flush(mut self):
        """Flush any buffered output."""
        self.handler.flush()

    fn close(mut self):
        """Clean up resources."""
        self.handler.close()
