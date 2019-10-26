//
//  LogMessageTests.swift
//  HaikooTests
//
//  Created by Paolo Ardia on 13/10/2019.
//

import XCTest
import Haikoo

// MARK: - Helper Classes

struct TestMessage: LogMessage {
    let name: String
    let payload: [String: Any]

    init(_ name: String = "", payload: [String: Any] = [:]) {
        self.name = name
        self.payload = payload
    }
}

extension Haikoo {
    func logWithAllLogLevels(message: LogMessage) {
        debug(message)
        verbose(message)
        info(message)
        warning(message)
        error(message)
        fatal(message)
    }
    
    func logWithAllLogLevels(string: String) {
        debug(string)
        verbose(string)
        info(string)
        warning(string)
        error(string)
        fatal(string)
    }
}

// MARK: - Message Tests

class SynchronousBlabberMessageLogLevelTestCase: SynchronousBlabberTestCase {
    func testThatItLogsAsExpectedWithOffLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .off)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 0, "Actual number of writes should be 0")
    }

    func testThatItLogsAsExpectedWithDebugLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .debug)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }
    
    func testThatItLogsAsExpectedWithVerboseLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .verbose)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithInfoLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .info)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithWarningLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .warning)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithErrorLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .error)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }
    
    func testThatItLogsAsExpectedWithFatalLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .fatal)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAllLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .all)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 6, "Actual number of writes should be 6")
    }

    func testThatItLogsAsExpectedWithMultipleLogLevels() {
        // Given
        let logLevels: LogLevel = [.debug, .verbose, .error]
        let (log, messenger) = logger(logLevels: logLevels)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 3, "Actual number of writes should be 3")
    }

    func testThatItCanLogMessageInsideAnotherLogStatement() {
        // Given
        let (log, messenger) = logger(logLevels: .all)
        let message = TestMessage()

        // When
        log.debug ({ () -> LogMessage in
            log.debug(message)
            return message
        })

        log.verbose ({ () -> LogMessage in
            log.verbose(message)
            return message
        })

        log.info ({ () -> LogMessage in
            log.info(message)
            return message
        })

        log.warning ({ () -> LogMessage in
            log.warning(message)
            return message
        })

        log.error ({ () -> LogMessage in
            log.error(message)
            return message
        })
        
        log.fatal ({ () -> LogMessage in
            log.fatal(message)
            return message
        })

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 12, "Actual number of writes should be 12")
    }

    func testThatItLogsAsExpectedWithAutoclosureDebugLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .debug)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }
    
    func testThatItLogsAsExpectedWithAutoclosureVerboseLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .verbose)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureInfoLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .info)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }
    
    func testThatItLogsAsExpectedWithAutoclosureWarningLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .warning)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureErrorLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .error)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureFatalLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .fatal)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }
}

// MARK: -

class AsynchronousBlabberMessageLogLevelTestCase: AsynchronousBlabberTestCase {
    func testThatItLogsAsExpectedWithOffLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .off, expectedNumberOfWrites: 0)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // This is an interesting test because we have to wait to make sure nothing happened. This makes it
        // very difficult to fullfill the expectation. For now, we are using a dispatch_after that fires
        // slightly before the timeout to fullfill the expectation.

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            messenger.expectation.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithDebugLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .debug, expectedNumberOfWrites: 1)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }
    
    func testThatItLogsAsExpectedWithVerboseLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .verbose, expectedNumberOfWrites: 1)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }
    
    func testThatItLogsAsExpectedWithInfoLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .info, expectedNumberOfWrites: 1)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }
    
    func testThatItLogsAsExpectedWithWarningLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .warning, expectedNumberOfWrites: 1)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }
    
    func testThatItLogsAsExpectedWithErrorLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .error, expectedNumberOfWrites: 1)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }
    
    func testThatItLogsAsExpectedWithFatalLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .fatal, expectedNumberOfWrites: 1)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithMultipleLogLevels() {
        // Given
        let logLevels: LogLevel = [.verbose, .warning, .error]
        let (log, messenger) = logger(logLevels: logLevels, expectedNumberOfWrites: 3)
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItCanLogMessageInsideAnotherLogStatement() {
        // Given
        let (log, messenger) = logger(logLevels: .all, expectedNumberOfWrites: 12)
        let message = TestMessage()

        // When
        log.debug ({ () -> LogMessage in
            log.debug(TestMessage())
            return message
        })
        
        log.verbose ({ () -> LogMessage in
            log.verbose(TestMessage())
            return message
        })
        
        log.info ({ () -> LogMessage in
            log.info(TestMessage())
            return message
        })
        
        log.warning ({ () -> LogMessage in
            log.warning(TestMessage())
            return message
        })
        
        log.error ({ () -> LogMessage in
            log.error(TestMessage())
            return message
        })

        log.fatal ({ () -> LogMessage in
            log.fatal(TestMessage())
            return message
        })

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites)
    }

    func testPayloadIsWritten() {
        // Given
        let (log, messenger) = logger(logLevels: .all, expectedNumberOfWrites: 1)
        let message = TestMessage("Hello world", payload: ["P1": "Value", "P2": 3])

        // When
        log.debug(message)

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites)
        XCTAssertEqual(messenger.lastMessage?.name, message.name)
        XCTAssertEqual(messenger.lastMessage?.payload.count, message.payload.count)
        XCTAssertEqual(messenger.lastMessage?.payload["P1"] as? String, "Value")
        XCTAssertEqual(messenger.lastMessage?.payload["P2"] as? Int, 3)
    }
}

// MARK: -

class SynchronousBlabberEnabledMessageTestCase: SynchronousBlabberTestCase {
    func testThatItLogsAllLogLevelsWhenEnabled() {
        // Given
        let (log, messenger) = logger(logLevels: .all)
        log.enabled = true
        let message = TestMessage()

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 6, "Actual number of writes should be equal to 6")
    }

    func testThatNoLoggingOccursForAnyLogLevelWhenDisabled() {
        // Given
        let (log, messenger) = logger(logLevels: .all)
        let message = TestMessage()
        log.enabled = false

        // When
        log.logWithAllLogLevels(message: message)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 0, "Actual number of writes should be equal to 0")
    }
}

// MARK: - String Tests

class SynchronousBlabberLogLevelTestCase: SynchronousBlabberTestCase {
    func testThatItLogsAsExpectedWithOffLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .off)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 0, "Actual number of writes should be 0")
    }

    func testThatItLogsAsExpectedWithDebugLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .debug)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }
    
    func testThatItLogsAsExpectedWithVerboseLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .verbose)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithInfoLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .info)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithWarningLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .warning)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithErrorLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .error)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithFatalLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .fatal)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAllLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .all)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 6, "Actual number of writes should be 6")
    }

    func testThatItLogsAsExpectedWithMultipleLogLevels() {
        // Given
        let logLevels: LogLevel = [.debug, .verbose, .error]
        let (log, messenger) = logger(logLevels: logLevels)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 3, "Actual number of writes should be 3")
    }

    func testThatItCanLogMessageInsideAnotherLogStatement() {
        // Given
        let (log, messenger) = logger(logLevels: .all)

        // When
        log.debug ({ () -> String in
            log.debug("")
            return ""
        })
        
        log.verbose ({ () -> String in
            log.verbose("")
            return ""
        })
        
        log.info ({ () -> String in
            log.info("")
            return ""
        })
        
        log.warning ({ () -> String in
            log.warning("")
            return ""
        })
        
        log.error ({ () -> String in
            log.error("")
            return ""
        })
        
        log.fatal ({ () -> String in
            log.fatal("")
            return ""
        })

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 12, "Actual number of writes should be 12")
    }

    func testThatItLogsAsExpectedWithAutoclosureDebugLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .debug)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }
    
    func testThatItLogsAsExpectedWithAutoclosureVerboseLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .verbose)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureInfoLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .info)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureWarningLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .warning)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureErrorLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .error)

        // When
        log.logWithAllLogLevels(string: "")
        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureFatalLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .fatal)

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }
}

// MARK: -

class AsynchronousBlabberLogLevelTestCase: AsynchronousBlabberTestCase {
    func testThatItLogsAsExpectedWithOffLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .off, expectedNumberOfWrites: 0)

        // When
        log.logWithAllLogLevels(string: "")

        // This is an interesting test because we have to wait to make sure nothing happened. This makes it
        // very difficult to fullfill the expectation. For now, we are using a dispatch_after that fires
        // slightly before the timeout to fullfill the expectation.

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            messenger.expectation.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithDebugLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .debug, expectedNumberOfWrites: 1)

        // When
        log.logWithAllLogLevels(string: "")

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }
    
    func testThatItLogsAsExpectedWithVerboseLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .verbose, expectedNumberOfWrites: 1)

        // When
        log.logWithAllLogLevels(string: "")

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithInfoLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .info, expectedNumberOfWrites: 1)

        // When
        log.logWithAllLogLevels(string: "")

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithWarningLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .warning, expectedNumberOfWrites: 1)

        // When
        log.logWithAllLogLevels(string: "")

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithErrorLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .error, expectedNumberOfWrites: 1)

        // When
        log.logWithAllLogLevels(string: "")

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithFatalLogLevel() {
        // Given
        let (log, messenger) = logger(logLevels: .fatal, expectedNumberOfWrites: 1)

        // When
        log.logWithAllLogLevels(string: "")

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithMultipleLogLevels() {
        // Given
        let logLevels: LogLevel = [.verbose, .warning, .error]
        let (log, messenger) = logger(logLevels: logLevels, expectedNumberOfWrites: 3)

        // When
        log.logWithAllLogLevels(string: "")

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItCanLogMessageInsideAnotherLogStatement() {
        // Given
        let (log, messenger) = logger(logLevels: .all, expectedNumberOfWrites: 12)

        // When
        log.debug ({ () -> String in
            log.debug("")
            return ""
        })
        
        log.verbose ({ () -> String in
            log.verbose("")
            return ""
        })
        
        log.info ({ () -> String in
            log.info("")
            return ""
        })
        
        log.warning ({ () -> String in
            log.warning("")
            return ""
        })
        
        log.error ({ () -> String in
            log.error("")
            return ""
        })
        
        log.fatal ({ () -> String in
            log.fatal("")
            return ""
        })
    
        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, messenger.expectedNumberOfWrites)
    }
}

// MARK: -

class SynchronousBlabberEnabledTestCase: SynchronousBlabberTestCase {
    func testThatItLogsAllLogLevelsWhenEnabled() {
        // Given
        let (log, messenger) = logger(logLevels: .all)
        log.enabled = true

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 6, "Actual number of writes should be equal to 6")
    }

    func testThatNoLoggingOccursForAnyLogLevelWhenDisabled() {
        // Given
        let (log, messenger) = logger(logLevels: .all)
        log.enabled = false

        // When
        log.logWithAllLogLevels(string: "")

        // Then
        XCTAssertEqual(messenger.actualNumberOfWrites, 0, "Actual number of writes should be equal to 0")
    }
}
