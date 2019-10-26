//
//  SymbolsFormatter.swift
//  Haikoo
//
//  Created by Paolo Ardia on 14/10/2019.
//

import Foundation

/// The SymbolsFormatter class applies emojies to the beginning of the message.
open class SymbolsFormatter: LogFormatter {
    
    
    /// Symbols to use as prefix of the log message
    let symbols: String
    
    /// Initializes a `SymbolsFormatter` instance.
    ///
    /// - Parameter symbols: symbols to use as prefix of the log message.
    ///
    /// - Returns: A new `SymbolsFormatter` instance.
    public init(symbols: String) {
        self.symbols = symbols
    }

    /// Applies emojies to the beginning of the message.
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
        var symbols = self.symbols
        switch logLevel {
        case .warning:
            symbols = "⚠️⚠️⚠️"
        case .error:
            symbols = "💥🧨💥"
        case .fatal:
            symbols = "☠️⚰️☠️"
        default:
            break
        }
        return "\(symbols) \(message)"
    }
}
