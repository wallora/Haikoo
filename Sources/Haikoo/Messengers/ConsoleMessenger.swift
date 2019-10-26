//
//  ConsoleMessenger.swift
//  Haikoo
//
//  Created by Paolo Ardia on 14/10/2019.
//

import Foundation

/// The ConsoleMessenger class runs all formatters in the order they were created and prints the resulting message
/// to the console.
open class ConsoleMessenger: LogFormatterMessenger, LogTruncatingMessenger {

    /// Array of formatters that the messenger should execute (in order) on incoming messages.
    public let formatters: [LogFormatter]
    
    /// Maximum length of a message. If the message is longer than this value, it will be truncated.
    /// Default value is 0 (no truncation).
    public var maxMessageLength: Int

    /// Initializes a console messenger instance.
    ///
    /// - Parameter formatters: Array of formatters that the writer should execute (in order) on incoming messages.
    /// - Parameter maxMessageLength: Maximum length of a message.
    ///
    /// - Returns: A new console writer instance.
    public init(formatters: [LogFormatter] = [], maxMessageLength: Int = 0) {
        self.formatters = formatters
        self.maxMessageLength = maxMessageLength
    }

    /// Dispatches the message to the console using the global `print` function.
    ///
    /// Each formatter is run over the message in the order they are provided before dispatching the message to
    /// the console.
    ///
    /// - Parameters:
    ///   - message:   The original message to dispatch to the console.
    ///   - logLevel:  The log level associated with the message.
    ///   - file: tha path of the file that calls this function.
    ///   - function: the name of the caller function.
    ///   - line: the line of code that calls this function.
    open func dispatchMessage(_ message: String,
                              logLevel: LogLevel,
                              file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        let truncated = truncateMessage(message)
        let formatted = formatMessage(truncated, with: logLevel, file: file, function: function, line: line)
        print(formatted)
    }

    /// Dispatches the message to the console using the global `print` function.
    ///
    /// Each formatter is run over the message in the order they are provided before dispatching the message to
    /// the console.
    ///
    /// - Parameters:
    ///   - message:   The original message to dispatch to the console.
    ///   - logLevel:  The log level associated with the message.
    ///   - file: tha path of the file that calls this function.
    ///   - function: the name of the caller function.
    ///   - line: the line of code that calls this function.
    public func dispatchMessage(_ message: LogMessage,
                                logLevel: LogLevel,
                                file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        let truncated = truncateMessage("\(message.name): \(message.payload)")
        let formatted = formatMessage(truncated, with: logLevel, file: file, function: function, line: line)
        print(formatted)
    }
}
