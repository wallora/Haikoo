//
//  BlabberTests.swift
//  HaikooTests
//
//  Created by Paolo Ardia on 13/10/2019.
//

import XCTest
import Haikoo

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

// MARK: Test Helpers

class SynchronousTestMessenger: LogFormatterMessenger {
    private(set) var actualNumberOfWrites: Int = 0
    private(set) var message: String?
    private(set) var formattedMessages = [String]()

    let formatters: [LogFormatter]
    var lastMessage: LogMessage?

    init(formatters: [LogFormatter] = []) {
        self.formatters = formatters
    }

    func dispatchMessage(_ message: String, logLevel: LogLevel, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        var mutableMessage = message

        formatters.forEach { mutableMessage = $0.formatMessage(mutableMessage, with: logLevel, file: file, function: function, line: line) }
        formattedMessages.append(mutableMessage)

        self.message = mutableMessage

        actualNumberOfWrites += 1
    }

    func dispatchMessage(_ message: LogMessage, logLevel: LogLevel, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        var mutableMessage = "\(message.name): \(message.payload)"

        lastMessage = message

        formatters.forEach { mutableMessage = $0.formatMessage(mutableMessage, with: logLevel, file: file, function: function, line: line) }
        formattedMessages.append(mutableMessage)

        self.message = mutableMessage

        actualNumberOfWrites += 1
    }
}

class AsynchronousTestMessenger: SynchronousTestMessenger {
    let expectation: XCTestExpectation
    let expectedNumberOfWrites: Int

    init(expectation: XCTestExpectation, expectedNumberOfWrites: Int, formatters: [LogFormatter] = []) {
        self.expectation = expectation
        self.expectedNumberOfWrites = expectedNumberOfWrites
        super.init(formatters: formatters)
    }

    override func dispatchMessage(_ message: String, logLevel: LogLevel, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        super.dispatchMessage(message, logLevel: logLevel)

        if actualNumberOfWrites == expectedNumberOfWrites {
            expectation.fulfill()
        }
    }

    override func dispatchMessage(_ message: LogMessage, logLevel: LogLevel, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        super.dispatchMessage(message, logLevel: logLevel)

        if actualNumberOfWrites == expectedNumberOfWrites {
            expectation.fulfill()
        }
    }
}

class TestFormatter: LogFormatter {
    func formatMessage(_ message: String, with logLevel: LogLevel, file: StaticString, function: StaticString, line: UInt) -> String {
        return "[TEST] \(message)"
    }
}

// MARK: - Base Test Cases

class SynchronousBlabberTestCase: XCTestCase {
    var message = "Test Message"
    let timeout = 0.1

    func logger(logLevels: LogLevel = .all, formatters: [LogFormatter] = []) -> (Haikoo, SynchronousTestMessenger) {
        let messenger = SynchronousTestMessenger(formatters: formatters)
        let logger = Haikoo(logLevels: logLevels, messengers: [messenger])

        return (logger, messenger)
    }

    func logger(messengers: [LogMessenger] = []) -> (Haikoo) {
        let logger = Haikoo(logLevels: [.all], messengers: messengers)

        return logger
    }
}

class AsynchronousBlabberTestCase: SynchronousBlabberTestCase {
    func logger(
        logLevels: LogLevel = .debug,
        formatters: [LogFormatter] = [],
        expectedNumberOfWrites: Int = 1) -> (Haikoo, AsynchronousTestMessenger)
    {
        let expectation = self.expectation(description: "Test writer should receive expected number of writes")
        let messenger = AsynchronousTestMessenger(expectation: expectation, expectedNumberOfWrites: expectedNumberOfWrites, formatters: formatters)
        let queue = DispatchQueue(label: "async-blabber-queue", qos: .utility)
        let logger = Haikoo(logLevels: logLevels, messengers: [messenger], dispatchMethod: .asynchronous(queue: queue))

        return (logger, messenger)
    }
    
    func testPerformance() {
        let messenger = ConsoleMessenger()
        let blabber = Haikoo(logLevels: .debug, messengers: [messenger], dispatchMethod: .asynchronous(queue: Haikoo.defaultQueue))
        
        let message = "Test Message\n"
        var longMessage = message
        for _ in 0...100_000 {
            longMessage += message
        }
        
        measure {
            blabber.debug(longMessage)
        }
    }
}

class SynchronousBlabberMultiFormatterTestCase: SynchronousBlabberTestCase {
    private struct PlusFormatter: LogFormatter {
        func formatMessage(_ message: String, with logLevel: LogLevel, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) -> String {
            return "+++++ \(message)"
        }
    }

    func testThatItLogsOutputAsExpectedWithMultipleFormatters() {
        // Given
        let formatters: [LogFormatter] = [TestFormatter(), PlusFormatter()]
        let (log, messenger) = logger(formatters: formatters)

        // When
        log.debug(self.message)
        log.verbose(self.message)
        log.info(self.message)
        log.warning(self.message)
        log.error(self.message)
        log.fatal(self.message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 6, "Actual number of writes should be 6")
        XCTAssertEqual(messenger.formattedMessages.count, 6, "Formatted message count should be 6")

        let expected = "+++++ [TEST] Test Message"
        messenger.formattedMessages.forEach { XCTAssertEqual($0, expected) }
    }
}

class SynchronousBlabberMultiMessengerTestCase: SynchronousBlabberTestCase {
    func testThatItLogsOutputAsExpectedWithMultipleMessengers() {
        // Given
        let mess1 = SynchronousTestMessenger()
        let mess2 = SynchronousTestMessenger()
        let mess3 = SynchronousTestMessenger()
        let messengers = [mess1, mess2, mess3]
        let log = logger(messengers: messengers)

        // When
        log.debug(self.message)
        log.verbose(self.message)
        log.info(self.message)
        log.warning(self.message)
        log.error(self.message)
        log.fatal(self.message)

        // Then
        XCTAssertEqual(mess1.actualNumberOfWrites, 6, "writer 1 actual number of writes should be 6")
        XCTAssertEqual(mess2.actualNumberOfWrites, 6, "writer 2 actual number of writes should be 6")
        XCTAssertEqual(mess3.actualNumberOfWrites, 6, "writer 3 actual number of writes should be 6")
    }
}
