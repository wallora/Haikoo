//
//  LogMessenger.swift
//  Haikoo
//
//  Created by Paolo Ardia on 13/10/2019.
//

import Foundation
import os

/// The LogMessenger protocol defines a single API for dispatch a log message. The message can be dispatched in any way.
/// For example, it could dispatch the message to the console, to a file, remote log to a third party service, etc.
public protocol LogMessenger {
    func dispatchMessage(_ message: String, logLevel: LogLevel, file: StaticString, function: StaticString, line: UInt)
    func dispatchMessage(_ message: LogMessage, logLevel: LogLevel, file: StaticString, function: StaticString, line: UInt)
}

/// LogFormatterMessenger extends LogMessenger to allow for standard writers that utilize LogFormatters
/// to transform the message before being output.
public protocol LogFormatterMessenger: LogMessenger {
    /// Array of formatters that the writer should execute (in order) on incoming messages.
    var formatters: [LogFormatter] { get }
}

extension LogFormatterMessenger {
    /// Apply all of the LogFormatters to the incoming message and return a new message.
    /// The formatters are run in the order they are stored in `formatters`.
    ///
    /// - Parameters:
    ///   - message:  Original message.
    ///   - logLevel: Log level of message.
    ///   - file: tha path of the file that calls this function.
    ///   - function: the name of the caller function.
    ///   - line: the line of code that calls this function.   
    ///
    /// - Returns: The result of executing all the modifiers on the original message.
    public func formatMessage(_ message: String,
                            with logLevel: LogLevel,
                            file: StaticString = #file, function: StaticString = #function, line: UInt = #line) -> String {
        var message = message
        formatters.forEach { message = $0.formatMessage(message, with: logLevel, file: file, function: function, line: line) }
        return message
    }
}

public protocol LogTruncatingMessenger: LogMessenger {
    /// Maximum length of a message. If the message is longer than this value, it will be truncated.
    /// Default value is 0 (no truncation).
    var maxMessageLength: Int { get set }
}

extension LogTruncatingMessenger {
    
    /// Truncates the given message.
    ///
    /// - Parameter message: The message to truncate.
    ///
    /// - Returns: The truncated message.
    func truncateMessage(_ message: String) -> String {
        guard message.count > maxMessageLength, maxMessageLength > 0 else { return message }
        let truncationIndicator = "<…>"
        return String(message.prefix(maxMessageLength)).appending(truncationIndicator)
    }
}
