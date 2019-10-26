//
//  FunctionFormatter.swift
//  Haikoo
//
//  Created by Paolo Ardia on 14/10/2019.
//

import Foundation

/// The FunctionFormatter class applies filename, function and line at the end of the message.
open class FunctionFormatter: LogFormatter {
    
    /// Initializes a `FunctionFormatter` instance.
    ///
    /// - Returns: A new `FunctionFormatter` instance.
    public init() {}

    /// Applies filename, function and line at the end of the message.
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
        let fileString = URL(fileURLWithPath: file.withUTF8Buffer{ String(decoding: $0, as: UTF8.self) }).lastPathComponent
        return "\(message)\n\t\(fileString) \(function) #\(line)"
    }
}
