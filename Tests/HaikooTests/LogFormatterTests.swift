//
//  LogFormatterTests.swift
//  HaikooTests
//
//  Created by Paolo Ardia on 13/10/2019.
//

import XCTest
import Haikoo

class TimestampFormatterTests: XCTestCase {

    // MARK: Tests
    func testThatItFormatsMessagesAsExpected() {
        // Given
        let formatter = TimestampFormatter()
        let message = "Test Message"
        let logLevels: [LogLevel] = [.error, .warning, .verbose, .info, .debug]

        // When
        let actualMessages = logLevels.map { formatter.formatMessage(message, with: $0) }

        // Then
        for (index, _) in logLevels.enumerated() {
            let actualMessage = actualMessages[index]
            let expectedSuffix = " \(message)"
            XCTAssertTrue(actualMessage.hasSuffix(expectedSuffix), "Actual message should contain expected suffix")
            XCTAssertEqual(actualMessage.count, 37, "Actual message 37 characters")
        }
    }
}

class SymbolsFormatterTests: XCTestCase {

    // MARK: Tests
    func testThatItFormatsMessagesAsExpectedWithWarningLogLevel() {
        // Given
        let formatter = SymbolsFormatter(symbols: "🏁🏁🏁")
        let message = "Test Message"

        // When
        let actualMessage = formatter.formatMessage(message, with: .warning)

        // Then
        let expectedPrefix = "⚠️⚠️⚠️"
        XCTAssertTrue(actualMessage.hasPrefix(expectedPrefix), "Actual message should contain expected prefix")
        XCTAssertEqual(actualMessage.count, 16, "Actual message 16 characters")
    }
    
    func testThatItFormatsMessagesAsExpectedWithErrorLogLevel() {
        // Given
        let formatter = SymbolsFormatter(symbols: "🏁🏁🏁")
        let message = "Test Message"

        // When
        let actualMessage = formatter.formatMessage(message, with: .error)

        // Then
        let expectedPrefix = "💥🧨💥"
        XCTAssertTrue(actualMessage.hasPrefix(expectedPrefix), "Actual message should contain expected prefix")
        XCTAssertEqual(actualMessage.count, 16, "Actual message 16 characters")
    }
    
    func testThatItFormatsMessagesAsExpectedWithFatalLogLevel() {
        // Given
        let formatter = SymbolsFormatter(symbols: "🏁🏁🏁")
        let message = "Test Message"

        // When
        let actualMessage = formatter.formatMessage(message, with: .fatal)

        // Then
        let expectedPrefix = "☠️⚰️☠️"
        XCTAssertTrue(actualMessage.hasPrefix(expectedPrefix), "Actual message should contain expected prefix")
        XCTAssertEqual(actualMessage.count, 16, "Actual message 16 characters")
    }
    
    func testThatItFormatsMessagesAsExpectedWithAnotherLogLevel() {
        // Given
        let formatter = SymbolsFormatter(symbols: "🏁🏁🏁")
        let message = "Test Message"

        // When
        let actualMessage = formatter.formatMessage(message, with: .verbose)

        // Then
        let expectedPrefix = "🏁🏁🏁"
        XCTAssertTrue(actualMessage.hasPrefix(expectedPrefix), "Actual message should contain expected prefix")
        XCTAssertEqual(actualMessage.count, 16, "Actual message 16 characters")
    }
}


class FunctionFormatterTests: XCTestCase {

    // MARK: Tests
    func testThatItFormatsMessagesAsExpected() {
        // Given
        let formatter = FunctionFormatter()
        let message = "Test Message"

        // When
        let actualMessage = formatter.formatMessage(message, with: .error)

        // Then
        let expectedPrefix = "\(message)"
        XCTAssertTrue(actualMessage.hasPrefix(expectedPrefix), "Actual message should contain expected prefix")
        XCTAssertEqual(actualMessage.count, 80, "Actual message 80 characters")
    }
}

class CompleteFormatterTests: XCTestCase {

    // MARK: Tests
    func testThatItFormatsMessagesAsExpected() {
        // Given
        let formatter = CompleteFormatter(symbols: "🏁🏁🏁")
        let message = "Test Message"

        // When
        let actualMessage = formatter.formatMessage(message, with: .error)
        // Then
        XCTAssertEqual(actualMessage.count, 109, "Actual message 109 characters")
    }
}
