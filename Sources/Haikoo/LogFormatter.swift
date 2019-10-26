//
//  LogFormatter.swift
//  Haikoo
//
//  Created by Paolo Ardia on 13/10/2019.
//

import Foundation

/// The LogFormatter protocol defines a single method for modifying a log message after it has been constructed.
public protocol LogFormatter {
    /// Formats the message.
    ///
    /// - Parameters:
    ///   - message:  The original message to format.
    ///   - logLevel: The log level set for the message.
    ///   - file: tha path of the file that calls this function.
    ///   - function: the name of the caller function.
    ///   - line: the line of code that calls this function.
    ///
    /// - Returns: A newly formatted message.
    func formatMessage(_ message: String,
                       with logLevel: LogLevel,
                       file: StaticString, function: StaticString, line: UInt) -> String
}
