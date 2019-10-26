//
//  TimestampFormatter.swift
//  Haikoo
//
//  Created by Paolo Ardia on 14/10/2019.
//

import Foundation

/// The TimestampFormatter class applies a timestamp to the beginning of the message.
open class TimestampFormatter: LogFormatter {
    private let timestampFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    /// Initializes a `TimestampFormatter` instance.
    ///
    /// - Returns: A new `TimestampFormatter` instance.
    public init() {}

    /// Applies a timestamp to the beginning of the message.
    ///
    /// - Parameters:
    ///   - message:  The original message to format.
    ///   - logLevel: The log level set for the message.
    ///   - file: tha path of the file that calls this function.
    ///   - function: the name of the caller function.
    ///   - line: the line of code that calls this function.
    ///
    /// - Returns: A newly formatted message.
    open func formatMessage(_ message: String,
                            with logLevel: LogLevel,
                            file: StaticString = #file, function: StaticString = #function, line: UInt = #line) -> String {
        let timestampString = timestampFormatter.string(from: Date())
        return "\(timestampString): \(message)"
    }
}
