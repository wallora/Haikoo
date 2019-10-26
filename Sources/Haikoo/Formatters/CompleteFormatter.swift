//
//  CompleteFormatter.swift
//  Haikoo
//
//  Created by Paolo Ardia on 14/10/2019.
//

import Foundation

/// The CompleteFormatter class uses `TimestampFormatter`, `SymbolsFormatter` and `FunctionFormatter` in this order to format the message.
open class CompleteFormatter: LogFormatter {
    
    /// Ordered list of subformatters that should be used to modify the log message.
    public var subformatters: [LogFormatter]
    
    /// Initializes a `CompleteFormatter` instance.
    ///
    /// - Parameter symbols: symbols to use as prefix of the log message.
    ///
    /// - Returns: A new `CompleteFormatter` instance.
    public init(symbols: String) {
        self.subformatters = [TimestampFormatter(), SymbolsFormatter(symbols: symbols), FunctionFormatter()]
    }
    
    /// Uses `TimestampFormatter`, `SymbolsFormatter` and `SymbolsFormatter` in this order to format the message.
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
        return subformatters.reduce(message) { (result, formatter) -> String in
            return formatter.formatMessage(result, with: logLevel, file: file, function: function, line: line)
        }
    }
}
