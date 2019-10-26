//
//  LogMessengerTests.swift
//  HaikooTests
//
//  Created by Paolo Ardia on 13/10/2019.
//

import XCTest
import os
@testable import Haikoo

// MARK: - ConsoleMessenger

class ConsoleMessengerTestCase: XCTestCase {
    func testThatConsoleMessengerCanBeInitialized() {
        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let messenger = ConsoleMessenger()

        // When, Then
        messenger.dispatchMessage(message, logLevel: logLevel)
    }

    func testThatConsoleMessengerCanDispatchMessageToConsoleWithPrint() {
        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let messenger = ConsoleMessenger()

        // When, Then
        messenger.dispatchMessage(message, logLevel: logLevel)
    }
    
    func testThatConsoleMessengerCanDispatchLogMessageToConsoleWithPrint() {
        // Given
        let message = TestMessage("Test", payload: ["key": "value"])
        let logLevel: LogLevel = .all
        let messenger = ConsoleMessenger()

        // When, Then
        messenger.dispatchMessage(message, logLevel: logLevel)
    }
    
    func testTruncateMessage() {
        // Given
        let message = "Test Message"
        let messenger = ConsoleMessenger(maxMessageLength: 5)
        
        // When
        let truncatedMessage = messenger.truncateMessage(message)
        
        // Then
        XCTAssertEqual(truncatedMessage.count, 8)
    }
    
    func testPerformance() {
        // Given
        let message = "Test Message\n"
        var longMessage = message
        for _ in 0...1_000 {
            longMessage += message
        }
        let messenger = ConsoleMessenger()
        
        // Then
        self.measure {
            messenger.dispatchMessage(longMessage, logLevel: .debug)
        }
    }
}


// MARK: OSLogMessenger

class OSLogMessengerTestCase: XCTestCase {
    let subsystem = "com.sysdata.blabber.test"
    let category = "os-log-messenger"

    func testThatOSLogMessengerCanBeInitialized() {
        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let messenger = OSLogMessenger(subsystem: subsystem, category: category)

        // When, Then
        messenger.dispatchMessage(message, logLevel: logLevel)
    }

    func testThatOSLogMessengerCanDispatchMessageToOSLog() {
        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let messenger = OSLogMessenger(subsystem: subsystem, category: category)

        // When, Then
        messenger.dispatchMessage(message, logLevel: logLevel)
    }
    
    func testThatOSLogMessengerCanDispatchLogMessageToOSLog() {
        // Given
        let message = TestMessage("Test", payload: ["key": "value"])
        let logLevel: LogLevel = .all
        let messenger = OSLogMessenger(subsystem: subsystem, category: category)

        // When, Then
        messenger.dispatchMessage(message, logLevel: logLevel)
    }
}

// MARK: - FileMessenger

class FileMessengerTestCase: XCTestCase {
    
    override class func tearDown() {
        try! FileManager.default.removeItem(atPath: FileMessenger.defaultLogsDirectory())
    }
    
    func testThatFileMessengerCanBeInitialized() {
        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let messenger = FileMessenger()

        // When, Then
        messenger.dispatchMessage(message, logLevel: logLevel)
    }
    
    func testLogsDirectoryDefaultValue() {
        // Given, When
        let messenger = FileMessenger()
        
        // Then
        XCTAssertEqual(messenger.logsDirectory, FileMessenger.defaultLogsDirectory())
    }
    
    func testMaxFilesNumberDefaultValue() {
        // Given, When
        let messenger = FileMessenger()
        
        // Then
        XCTAssertEqual(messenger.maxFilesNumber, 5)
    }
    
    func testFilesProtectionTypeDefaultValue() {
        // Given
        let messenger = FileMessenger()
        
        // When, Then
        if LogFileManager.appRunsInBackgroundMode() {
            XCTAssertEqual(messenger.filesProtectionType, FileProtectionType.completeUntilFirstUserAuthentication)
        } else {
            XCTAssertEqual(messenger.filesProtectionType, FileProtectionType.completeUnlessOpen)
        }
    }
    
    func testFileMaximumSizeDefaultValue() {
        // Given, When
        let messenger = FileMessenger()
        
        // Then
        XCTAssertEqual(messenger.fileMaxSize, 1024*1024)
    }
    
    func testRollingFrequencyDefaultValue() {
        // Given, When
        let messenger = FileMessenger()
        
        // Then
        XCTAssertEqual(messenger.rollingFrequency, 60*60*24)
    }
    
    func testThatFileMessengerCanBeInitializedWithCustomValues() {
        // Given
        let directory = "Test/Directory"
        let filesNum: UInt = 8
        let protection = FileProtectionType.none
        let maxSize = UInt64(1024*1024*5)
        let rolling: TimeInterval = 60*3
        
        // When
        let messenger = FileMessenger(logsDirectory: directory, maxFilesNumber: filesNum, filesProtectionType: protection, fileMaxSize: maxSize, rollingFrequency: rolling)
        
        // Then
        XCTAssertEqual(messenger.logsDirectory, directory)
        XCTAssertEqual(messenger.maxFilesNumber, filesNum)
        XCTAssertEqual(messenger.filesProtectionType, protection)
        XCTAssertEqual(messenger.fileMaxSize, maxSize)
        XCTAssertEqual(messenger.rollingFrequency, rolling)
    }
    
    func testCurrentFileIsNotNil() {
        // Given, When
        let messenger = FileMessenger()
        
        // Then
        XCTAssertNotNil(messenger.currentFile)
    }
    
    func testDispatchMessageWithString() {
        // Given
        let messenger = FileMessenger(fileMaxSize: 1, filePrefix: "Test Dispatch String")
        
        // When
        let file = messenger.currentFile.filePath
        messenger.dispatchMessage("Ciao", logLevel: .debug)
        
        // Then
        let fileString = try! String(contentsOfFile: file)
        XCTAssertEqual(fileString, "Ciao\n")
    }
    
    func testDispatchMessageWithLogMessage() {
        // Given
        let messenger = FileMessenger(fileMaxSize: 1)
        
        // When
        let file = messenger.currentFile.filePath
        let message = TestMessage("Ciao", payload: ["key":"value"])
        messenger.dispatchMessage(message, logLevel: .debug)
        
        // Then
        let fileString = try! String(contentsOfFile: file)
        XCTAssertEqual(fileString, "Ciao: [\"key\": \"value\"]\n")
    }
}

class LogFileManagerTests: XCTestCase {
    
    override class func tearDown() {
        try? FileManager.default.removeItem(atPath: FileMessenger.defaultLogsDirectory())
    }
    
    func testNewLogFileName() {
        // Given
        let manager = LogFileManager(filePrefix: "Test File Name")
        
        // When
        let date = Date(timeIntervalSince1970: 0)
        let name = manager.newLogFileName(with: date)
        
        // Then
        XCTAssertEqual(name, "Test File Name 1970-01-01 00-00-00.log")
    }
    
    func testApplicationName() {
        // Given, When, Then
        XCTAssertEqual(LogFileManager.applicationName, "com.apple.dt.xctest.tool")
    }
    
    func testLogFileDateFormatterSettings() {
        // Given, When
        let manager = LogFileManager()
        let formatter = manager.logFileDateFormatter
        
        // Then
        XCTAssertEqual(formatter.dateFormat, "yyyy'-'MM'-'dd' 'HH'-'mm'-'ss'")
        XCTAssertEqual(formatter.locale.identifier, "en_US_POSIX")
        XCTAssertEqual(formatter.timeZone.secondsFromGMT(), 0)
    }
    
    func testCreateLogsDirectory() {
        // Given
        let manager = LogFileManager()
        
        // When
        try? FileManager.default.removeItem(atPath: manager.logsDirectory)
        XCTAssertFalse(FileManager.default.fileExists(atPath: manager.logsDirectory))
        try! manager.createLogsDirectoryIfNeeded()
        
        // Then
        XCTAssertTrue(FileManager.default.fileExists(atPath: manager.logsDirectory))
    }
    
    func testCreateNewLogFile() {
        // Given
        let manager = LogFileManager()
        
        // When
        let logFile = manager.createNewLogFile()
        
        // Then
        XCTAssertTrue(FileManager.default.fileExists(atPath: logFile.filePath))
    }
    
    func testDeleteOldLogFilesDueToNumber() {
        // Given
        let manager = LogFileManager(maxFilesNumber: 1)
        
        // When
        let file1 = manager.createNewLogFile()
        // Waits 2 seconds to create the second file
        let exp = expectation(description: "Creates the new file after 2 seconds")
        let _ = XCTWaiter.wait(for: [exp], timeout: 2)
        let file2 = manager.createNewLogFile()
        
        // Then
        XCTAssertFalse(FileManager.default.fileExists(atPath: file1.filePath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: file2.filePath))
    }
    
    func testIsFileReusableDueToSize() {
        // Given
        let messenger = FileMessenger(fileMaxSize: 1)
        
        // When, Then
        let file = messenger.currentFile
        XCTAssertTrue(messenger.fileManager.isFileReusableDueToSize(file: file))
        messenger.dispatchMessage("12345", logLevel: .debug)
        XCTAssertFalse(messenger.fileManager.isFileReusableDueToSize(file: file))
    }
    
    func testIsFileReusableDueToAge() {
        // Given
        let manager = LogFileManager(rollingFrequency: 1)
        
        // When
        let file = manager.createNewLogFile()
        
        // Then
        XCTAssertTrue(manager.isFileReusableDueToAge(file: file))
        // Waits 2 seconds to test the negative case
        let exp = expectation(description: "Check file age after 2 seconds")
        let _ = XCTWaiter.wait(for: [exp], timeout: 2)
        XCTAssertFalse(manager.isFileReusableDueToAge(file: file))
    }
    
    func testIsFileReusableDueToAccessibility() {
        // Given
        let manager = LogFileManager()
        
        // When
        let file = manager.createNewLogFile()
        
        // Then
        XCTAssertTrue(manager.isFileReusableDueToAccessibility(file: file))
        // Cannot test the negative case
    }
    
    func testCurrentFileLog() {
        // Given
        let manager = LogFileManager(rollingFrequency: 1)
        
        // When, Then
        XCTAssertNotNil(manager.currentLogFile())
    }
    
    func testCurrentFileHandle() {
        // Given
        let manager = LogFileManager()
        
        // When, Then
        XCTAssertNotNil(manager.currentFileHandle())
    }
    
    func testScheduleFileRollingTimerWithoutRollingFrequency() {
        // Given
        let manager = LogFileManager(rollingFrequency: 0)
        
        // When, Then
        XCTAssertNil(manager.rollingTimer)
        let _ = manager.currentFileHandle()
        XCTAssertNil(manager.rollingTimer)
    }
    
    func testScheduleFileRollingTimerWithRollingFrequency() {
        // Given
        let manager = LogFileManager(rollingFrequency: 20)
        
        // When, Then
        XCTAssertNil(manager.rollingTimer)
        let _ = manager.currentFileHandle()
        XCTAssertNotNil(manager.rollingTimer)
    }
    
    func testRollFileDueToAgeWithoutRollingFrequency() {
        // Given
        let manager = LogFileManager(rollingFrequency: 0)
        
        // When, Then
        let _ = manager.currentLogFile()
        XCTAssertFalse(manager.rollFileDueToAge())
    }
    
    func testRollFileDueToAgeWithRollingFrequency() {
        // Given
        let manager = LogFileManager(rollingFrequency: 1)
        
        // When, Then
        let _ = manager.currentLogFile()
        XCTAssertFalse(manager.rollFileDueToAge())
        // Waits 2 seconds to test the negative case
        let exp = expectation(description: "Check file age after 2 seconds")
        let _ = XCTWaiter.wait(for: [exp], timeout: 2)
        XCTAssertTrue(manager.rollFileDueToAge())
    }
}

class LogFileTests: XCTestCase {
    func testLogFileDefaultValues() {
        // Given, When
        let file = LogFile(with: "Test/Logs/file_1.log")
        
        // Then
        XCTAssertEqual(file.filePath, "Test/Logs/file_1.log")
        XCTAssertEqual(file.fileName, "file_1.log")
        XCTAssertEqual(file.fileAttributes.count, 0)
        XCTAssertNil(file.modificationDate)
        XCTAssertNil(file.creationDate)
        XCTAssertEqual(file.fileSize, 0)
        XCTAssertEqual(file.protectionType, FileProtectionType.none)
    }
}
