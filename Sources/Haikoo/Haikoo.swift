//
//  Haiku.swift
//  Haikoo
//
//  Created by Paolo Ardia on 13/10/2019.
//

import Foundation

/// The Haiku class is a thread-safe, synchronous or asynchronous logging solution that
/// allows custom Formatters and Messengers. It determines whether to log a particular
/// message with a given log level.
///
/// Blabbers must be configured during initialization. If you need to change a blabber at runtime, it is advised to
/// create an additional blabber with a custom configuration to fit your needs.
open class Haikoo {
    
    // MARK: - Helper Types
    
    /// Defines the two types of dispatch methods used when logging a message.
    ///
    /// - synchronous:  Logs messages synchronously once the recursive lock is available in serial order. Use it only during the development.
    /// - asynchronous: Logs messages asynchronously on the dispatch queue in a serial order. It has better performances, use this method in production.
    public enum DispatchMethod {
        case synchronous(lock: NSRecursiveLock)
        case asynchronous(queue: DispatchQueue)
    }
    
    // MARK: - Properties
    
    /// A logger that does not output any messages to writers.
    public static let mute: Haikoo = MuteBlabber()
    
    /// Controls whether to allow log messages to be sent to the messengers.
    open var enabled = true
    
    /// Log level this blabber is configured for.
    public let logLevels: LogLevel
    
    /// The array of messengers to use when messages are dispatched.
    public let messengers: [LogMessenger]
    
    /// The dispatch method used when logging a message.
    public let dispatchMethod: DispatchMethod
    
    /// Default logging queue
    public static let defaultQueue = DispatchQueue(label: "com.blabber.queue", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .never, target: nil)
    
    // MARK: - Initialization
    
    /// Initializes a logger instance.
    ///
    /// - Parameters:
    ///   - logLevel:       The message level that should be logged to the messengers.
    ///   - messengers:      Array of messengers that messages should be sent to.
    ///   - dispatchMethod:  The dispatch method used when logging a message. `.synchronous` by default. In production you should use `.asynchronous(queue: Haiku.defaultQueue)` or passing your own queue.
    public init(
        logLevels: LogLevel,
        messengers: [LogMessenger],
        dispatchMethod: DispatchMethod = .synchronous(lock: NSRecursiveLock()))
    {
        self.logLevels = logLevels
        self.messengers = messengers
        self.dispatchMethod = dispatchMethod
    }
    
    // MARK: - Log Messages
    
    /// Dispatches the given message using the logger if the verbose log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func verbose(_ message: @autoclosure @escaping () -> LogMessage,
                      file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.verbose)
    }
    
    /// Dispatches the given message using the logger if the v log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func verbose(_ message: @escaping () -> LogMessage,
                      file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.verbose)
    }
    
    /// Dispatches the given message using the logger if the debug log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func debug(_ message: @autoclosure @escaping () -> LogMessage,
                    file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.debug)
    }
    
    /// Dispatches the given message using the logger if the debug log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func debug(_ message: @escaping () -> LogMessage,
                    file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.debug)
    }
    
    /// Dispatches the given message using the logger if the info log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func info(_ message: @autoclosure @escaping () -> LogMessage,
                   file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.info)
    }
    
    /// Dispatches the given message using the logger if the info log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func info(_ message: @escaping () -> LogMessage,
                   file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.info)
    }
    
    /// Dispatches the given message using the logger if the warning log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func warning(_ message: @autoclosure @escaping () -> LogMessage,
                      file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.warning)
    }
    
    /// Dispatches the given message using the logger if the warning log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func warning(_ message: @escaping () -> LogMessage,
                      file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.warning)
    }
    
    /// Dispatches the given message using the logger if the error log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func error(_ message: @autoclosure @escaping () -> LogMessage,
                    file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.error)
    }
    
    /// Dispatches the given message using the logger if the error log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func error(_ message: @escaping () -> LogMessage,
                    file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.error)
    }
    
    /// Dispatches the given message using the logger if the fatal log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func fatal(_ message: @autoclosure @escaping () -> LogMessage,
                    file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.fatal)
    }
    
    /// Dispatches the given message using the logger if the fatal log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func fatal(_ message: @escaping () -> LogMessage,
                    file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.fatal)
    }
    
    /// Dispatches the given message closure string with the logger if the log level is allowed.
    ///
    /// - Parameters:
    ///   - message:  A closure returning the message to log.
    ///   - logLevel: The log level associated with the message closure.
    ///   - file: tha path of the file that calls this function.
    ///   - function: the name of the caller function.
    ///   - line: the line of code that calls this function.
    open func logMessage(_ message: @escaping () -> (LogMessage),
                         with logLevel: LogLevel,
                         file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        guard enabled && isLogLevelAllowed(logLevel) else { return }
        
        switch dispatchMethod {
        case .synchronous(let lock):
            let message = message()
            lock.lock() ; defer { lock.unlock() }
            logMessage(message, with: logLevel, file: file, function: function, line: line)
            
        case .asynchronous(let queue):
            queue.async { self.logMessage(message(), with: logLevel, file: file, function: function, line: line) }
        }
    }
    
    // MARK: - Log String Messages
    
    /// Dispatches the given message using the logger if the verbose log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func verbose(_ message: @autoclosure @escaping () -> String,
                      file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.verbose, file: file, function: function, line: line)
    }
    
    /// Dispatches the given message using the logger if the verbose log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func verbose(_ message: @escaping () -> String,
                      file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.verbose, file: file, function: function, line: line)
    }
    
    /// Dispatches the given message using the logger if the debug log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func debug(_ message: @autoclosure @escaping () -> String,
                    file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.debug, file: file, function: function, line: line)
    }
    
    /// Dispatches the given message using the logger if the debug log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func debug(_ message: @escaping () -> String,
                    file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.debug, file: file, function: function, line: line)
    }
    
    /// Dispatches the given message using the logger if the info log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func info(_ message: @autoclosure @escaping () -> String,
                   file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.info, file: file, function: function, line: line)
    }
    
    /// Dispatches the given message using the logger if the info log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func info(_ message: @escaping () -> String,
                   file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.info, file: file, function: function, line: line)
    }
    
    /// Dispatches the given message using the logger if the warning log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func warning(_ message: @autoclosure @escaping () -> String,
                      file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.warning, file: file, function: function, line: line)
    }
    
    /// Dispatches the given message using the logger if the warning log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func warning(_ message: @escaping () -> String,
                      file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.warning, file: file, function: function, line: line)
    }
    
    /// Dispatches the given message using the logger if the error log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func error(_ message: @autoclosure @escaping () -> String,
                    file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.error, file: file, function: function, line: line)
    }
    
    /// Dispatches the given message using the logger if the error log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func error(_ message: @escaping () -> String,
                    file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.error, file: file, function: function, line: line)
    }
    
    /// Dispatches the given message using the logger if the fatal log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func fatal(_ message: @autoclosure @escaping () -> String,
                    file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.fatal, file: file, function: function, line: line)
    }
    
    /// Dispatches the given message using the logger if the fatal log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    /// - Parameter file: tha path of the file that calls this function.
    /// - Parameter function: the name of the caller function.
    /// - Parameter line: the line of code that calls this function.
    open func fatal(_ message: @escaping () -> String,
                    file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        logMessage(message, with: LogLevel.fatal, file: file, function: function, line: line)
    }
    
    /// Dispatches the given message closure string with the logger if the log level is allowed.
    ///
    /// - Parameters:
    ///   - message:      A closure returning the message to log.
    ///   - withLogLevel: The log level associated with the message closure.
    ///   - file: tha path of the file that calls this function.
    ///   - function: the name of the caller function.
    ///   - line: the line of code that calls this function.
    open func logMessage(_ message: @escaping () -> String, with logLevel: LogLevel,
                         file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        guard enabled && isLogLevelAllowed(logLevel) else { return }
        
        switch dispatchMethod {
        case .synchronous(let lock):
            lock.lock() ; defer { lock.unlock() }
            logMessage(message(), with: logLevel, file: file, function: function, line: line)
            
        case .asynchronous(let queue):
            queue.async { self.logMessage(message(), with: logLevel, file: file, function: function, line: line) }
        }
    }
    
    // MARK: - Private - Log Message Helpers
    
    
    /// Checks if the given `LogLevel` is allowed by the receveir.
    ///
    /// - Parameter logLevel: The log level to check.
    private func isLogLevelAllowed(_ logLevel: LogLevel) -> Bool {
        return logLevels.contains(logLevel)
    }
    
    
    /// Passes the message to each receiver's messenger.
    ///
    /// - Parameter message: The message to dispatch.
    /// - Parameter logLevel: The message's level.
    /// - Parameter file: The caller's file.
    /// - Parameter function: The caller's function.
    /// - Parameter line: The caller's line number.
    private func logMessage(_ message: String,
                            with logLevel: LogLevel,
                            file: StaticString, function: StaticString, line: UInt) {
        messengers.forEach { $0.dispatchMessage(message, logLevel: logLevel, file: file, function: function, line: line) }
    }
    
    /// Passes the `LogMessage` to each receiver's messenger.
    ///
    /// - Parameter message: The message to dispatch.
    /// - Parameter logLevel: The message's level.
    /// - Parameter file: The caller's file.
    /// - Parameter function: The caller's function.
    /// - Parameter line: The caller's line number.
    private func logMessage(_ message: LogMessage,
                            with logLevel: LogLevel,
                            file: StaticString, function: StaticString, line: UInt) {
        messengers.forEach { $0.dispatchMessage(message, logLevel: logLevel, file: file, function: function, line: line) }
    }
    
    // MARK: - Private - Mute Blabber
    
    /// Utility class that provides a disabled logger.
    private final class MuteBlabber: Haikoo {
        init() {
            super.init(logLevels: .off, messengers: [])
            enabled = false
        }
        
        override func logMessage(_ message: @escaping () -> String,
                                 with logLevel: LogLevel,
                                 file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {}
    }
}
