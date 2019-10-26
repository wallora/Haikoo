//
//  OSLogMessenger.swift
//  Haikoo
//
//  Created by Paolo Ardia on 14/10/2019.
//

import Foundation
import os

/// The OSLogMessenger class runs all formatters in the order they were created and passes the resulting message
/// off to an OSLog with the specified subsystem and category.
open class OSLogMessenger: LogFormatterMessenger, LogTruncatingMessenger {
    
    /// The subsystem to pass to os_log
    public let subsystem: String
    
    /// The category to pass to os_log
    public let category: String

    /// Array of formatters that the messenger should execute (in order) on incoming messages.
    public let formatters: [LogFormatter]
    /// Maximum length of a message. If the message is longer than this value, it will be truncated.
    /// Default value is 0 (no truncation).
    public var maxMessageLength: Int

    private let log: OSLog

    /// Creates an `OSLogMessenger` instance from the specified `subsystem` and `category`.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem.
    ///   - category:  The category.
    ///   - formatters: Ordered list of `LogFormatter`s that should be used to modify the log message.
    ///   - maxMessageLength: Maximum length of a message.
    public init(subsystem: String, category: String, formatters: [LogFormatter] = [], maxMessageLength: Int = 0) {
        self.subsystem = subsystem
        self.category = category
        self.formatters = formatters
        self.log = OSLog(subsystem: subsystem, category: category)
        self.maxMessageLength = maxMessageLength
    }

    /// Dispatches the message to the `OSLog` using the `os_log` function.
    ///
    /// Each formatter is run over the message in the order they are provided before dispatching the message to
    /// the `OSLog`.
    ///
    /// - Parameters:
    ///   - message:   The original message to write to the OSLog.
    ///   - logLevel:  The log level associated with the message.
    ///   - file: tha path of the file that calls this function.
    ///   - function: the name of the caller function.
    ///   - line: the line of code that calls this function.
    open func dispatchMessage(_ message: String,
                              logLevel: LogLevel,
                              file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        let truncated = truncateMessage(message)
        let formatted = formatMessage(truncated, with: logLevel, file: file, function: function, line: line)
        let type = logType(forLogLevel: logLevel)
        os_log("%@", log: log, type: type, formatted)
    }

    /// Dispatch the message to the `OSLog` using the `os_log` function.
    ///
    /// Each formatter is run over the message in the order they are provided before dispatching the message to
    /// the `OSLog`.
    ///
    /// - Parameters:
    ///   - message:   The original message to write to the OSLog.
    ///   - logLevel:  The log level associated with the message.
    ///   - file: tha path of the file that calls this function.
    ///   - function: the name of the caller function.
    ///   - line: the line of code that calls this function.
    open func dispatchMessage(_ message: LogMessage,
                              logLevel: LogLevel,
                              file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        let truncated = truncateMessage("\(message.name): \(message.payload)")
        let formatted = formatMessage(truncated, with: logLevel, file: file, function: function, line: line)
        let type = logType(forLogLevel: logLevel)
        os_log("%@", log: log, type: type, formatted)
    }

    /// Returns the `OSLogType` to use for the specified `LogLevel`.
    ///
    /// - Parameter logLevel: The level to be map to a `OSLogType`.
    ///
    /// - Returns: An `OSLogType` corresponding to the `LogLevel`.
    open func logType(forLogLevel logLevel: LogLevel) -> OSLogType {
        switch logLevel {
        case LogLevel.debug     : return .debug
        case LogLevel.verbose   : return .default
        case LogLevel.info      : return .info
        case LogLevel.warning   : return .default
        case LogLevel.error     : return .error
        default                 : return .default
        }
    }
}
