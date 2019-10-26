//
//  LogLevelTests.swift
//  HaikooTests
//
//  Created by Paolo Ardia on 13/10/2019.
//

import XCTest
import Haikoo

// MARK: - Helper Classes

extension LogLevel {
    static let chat = LogLevel(rawValue: 0b00000000_00000000_00000001_00000000)
    static let summary = LogLevel(rawValue: 0b00000000_00000000_00000010_00000000)
}

extension Haikoo {
    fileprivate func chat(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: LogLevel.chat)
    }

    fileprivate func chat(_ message: @escaping () -> String) {
        logMessage(message, with: LogLevel.chat)
    }

    fileprivate func summary(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: LogLevel.summary)
    }

    fileprivate func summary(_ message: @escaping () -> String) {
        logMessage(message, with: LogLevel.summary)
    }
}

class TestMessenger: LogMessenger {
    private(set) var actualNumberOfWrites: Int = 0
    private(set) var message: String?

    func dispatchMessage(_ message: String,
                         logLevel: LogLevel,
                         file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        self.message = message
        actualNumberOfWrites += 1
    }

    func dispatchMessage(_ message: LogMessage,
                         logLevel: LogLevel,
                         file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        self.message = "\(message.name): \(message.payload)"
        actualNumberOfWrites += 1
    }
}

// MARK: -

class LogLevelTests: XCTestCase {

    // MARK: Tests
    
    func testLogLevelRawValues() {
        let off = LogLevel.off
        let shutUp = LogLevel.shutUp
        let debug = LogLevel.debug
        let verbose = LogLevel.verbose
        let info = LogLevel.info
        let warning = LogLevel.warning
        let error = LogLevel.error
        let fatal = LogLevel.fatal
        
        // Then
        XCTAssertEqual(off.rawValue, 0)
        XCTAssertEqual(shutUp.rawValue, 0)
        XCTAssertEqual(verbose.rawValue, 1)
        XCTAssertEqual(debug.rawValue, 2)
        XCTAssertEqual(info.rawValue, 4)
        XCTAssertEqual(warning.rawValue, 8)
        XCTAssertEqual(error.rawValue, 16)
        XCTAssertEqual(fatal.rawValue, 32)
    }
    
    func testLogLevelDescriptions() {
        let off = LogLevel.off
        let debug = LogLevel.debug
        let verbose = LogLevel.verbose
        let info = LogLevel.info
        let warning = LogLevel.warning
        let error = LogLevel.error
        let fatal = LogLevel.fatal
        let all = LogLevel.all
        let unknown = LogLevel(rawValue: 0b00000000_00001000_00000000_00000000)

        // Then
        XCTAssertEqual(off.description, "Off")
        XCTAssertEqual(debug.description, "Debug")
        XCTAssertEqual(verbose.description, "Verbose")
        XCTAssertEqual(info.description, "Info")
        XCTAssertEqual(warning.description, "Warning")
        XCTAssertEqual(error.description, "Error")
        XCTAssertEqual(fatal.description, "Fatal")
        XCTAssertEqual(all.description, "All")
        XCTAssertEqual(unknown.description, "Unknown")
    }
    
    func testLogLevelEquatableConformance() {
        // Given, When
        let off = LogLevel.off
        let shutUp = LogLevel.shutUp
        let debug = LogLevel.debug
        let verbose = LogLevel.verbose
        let info = LogLevel.info
        let warning = LogLevel.warning
        let error = LogLevel.error
        let fatal = LogLevel.fatal
        let all = LogLevel.all
        let logorrhoea = LogLevel.logorrhoea

        // Then
        XCTAssertEqual(off, off)
        XCTAssertEqual(shutUp, shutUp)
        XCTAssertEqual(off, shutUp)
        XCTAssertEqual(debug, debug)
        XCTAssertEqual(verbose, verbose)
        XCTAssertEqual(info, info)
        XCTAssertEqual(warning, warning)
        XCTAssertEqual(error, error)
        XCTAssertEqual(fatal, fatal)
        XCTAssertEqual(all, all)
        XCTAssertEqual(logorrhoea, logorrhoea)
        XCTAssertEqual(all, logorrhoea)

        XCTAssertNotEqual(off, debug)
        XCTAssertNotEqual(off, verbose)
        XCTAssertNotEqual(off, info)
        XCTAssertNotEqual(off, warning)
        XCTAssertNotEqual(off, error)
        XCTAssertNotEqual(off, fatal)
        XCTAssertNotEqual(off, all)
        XCTAssertNotEqual(off, logorrhoea)
        
        XCTAssertNotEqual(shutUp, debug)
        XCTAssertNotEqual(shutUp, verbose)
        XCTAssertNotEqual(shutUp, info)
        XCTAssertNotEqual(shutUp, warning)
        XCTAssertNotEqual(shutUp, error)
        XCTAssertNotEqual(shutUp, fatal)
        XCTAssertNotEqual(shutUp, all)
        XCTAssertNotEqual(shutUp, logorrhoea)

        XCTAssertNotEqual(debug, verbose)
        XCTAssertNotEqual(debug, info)
        XCTAssertNotEqual(debug, warning)
        XCTAssertNotEqual(debug, error)
        XCTAssertNotEqual(debug, fatal)
        XCTAssertNotEqual(debug, all)
        XCTAssertNotEqual(debug, logorrhoea)
        
        XCTAssertNotEqual(verbose, info)
        XCTAssertNotEqual(verbose, warning)
        XCTAssertNotEqual(verbose, error)
        XCTAssertNotEqual(verbose, fatal)
        XCTAssertNotEqual(verbose, all)
        XCTAssertNotEqual(verbose, logorrhoea)

        XCTAssertNotEqual(info, warning)
        XCTAssertNotEqual(info, error)
        XCTAssertNotEqual(info, fatal)
        XCTAssertNotEqual(info, all)
        XCTAssertNotEqual(info, logorrhoea)
        
        XCTAssertNotEqual(warning, error)
        XCTAssertNotEqual(warning, fatal)
        XCTAssertNotEqual(warning, all)
        XCTAssertNotEqual(warning, logorrhoea)

        XCTAssertNotEqual(error, fatal)
        XCTAssertNotEqual(error, all)
        XCTAssertNotEqual(error, logorrhoea)

        XCTAssertNotEqual(fatal, all)
        XCTAssertNotEqual(fatal, logorrhoea)
    }
}

// MARK: -

class CustomLogLevelTestCase: XCTestCase {

    // MARK: Tests

    func testThatItLogsAsExpectedWithAllLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .all)

        // When / Then
        log.chat("chat message")
        XCTAssertEqual("chat message", messenger.message ?? "", "Expected message should match actual messenger message")
        
        log.debug("debug message")
        XCTAssertEqual("debug message", messenger.message ?? "", "Expected message should match actual messenger message")
        
        log.verbose("verbose message")
        XCTAssertEqual("verbose message", messenger.message ?? "", "Expected message should match actual messenger message")

        log.info("info message")
        XCTAssertEqual("info message", messenger.message ?? "", "Expected message should match actual messenger message")

        log.summary("summary message")
        XCTAssertEqual("summary message", messenger.message ?? "", "Expected message should match actual messenger message")

        log.warning("warning message")
        XCTAssertEqual("warning message", messenger.message ?? "", "Expected message should match actual messenger message")

        log.error("error message")
        XCTAssertEqual("error message", messenger.message ?? "", "Expected message should match actual messenger message")

        log.fatal("fatal message")
        XCTAssertEqual("fatal message", messenger.message ?? "", "Expected message should match actual messenger message")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 8, "Actual number of writes should be 8")
    }

    func testThatItLogsAsExpectedWithOrdLogLevels() {
        // Given
        let logLevels: LogLevel = [LogLevel.chat, LogLevel.info, LogLevel.summary, LogLevel.warning]
        let (log, messenger) = logger(logLevels: logLevels)

        // When / Then
        log.chat("chat message")
        XCTAssertEqual("chat message", messenger.message ?? "", "Expected message should match actual messenger message")

        log.debug("debug message")
        XCTAssertEqual("chat message", messenger.message ?? "", "Expected message should match actual messenger message")
        
        log.verbose("verbose message")
        XCTAssertEqual("chat message", messenger.message ?? "", "Expected message should match actual messenger message")

        log.info("info message")
        XCTAssertEqual("info message", messenger.message ?? "", "Expected message should match actual messenger message")

        log.summary("summary message")
        XCTAssertEqual("summary message", messenger.message ?? "", "Expected message should match actual messenger message")

        log.warning("warning message")
        XCTAssertEqual("warning message", messenger.message ?? "", "Expected message should match actual messenger message")

        log.error("error message")
        XCTAssertEqual("warning message", messenger.message ?? "", "Expected message should match actual messenger message")
        
        log.fatal("fatal message")
        XCTAssertEqual("warning message", messenger.message ?? "", "Expected message should match actual messenger message")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 4, "Actual number of writes should be 4")
    }

    // MARK: Private - Helper Methods

    func logger(logLevels: LogLevel) -> (Haikoo, TestMessenger) {
        let messenger = TestMessenger()
        let logger = Haikoo(logLevels: logLevels, messengers: [messenger])

        return (logger, messenger)
    }
}
