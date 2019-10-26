//
//  FileMessenger.swift
//  Haikoo
//
//  Created by Paolo Ardia on 14/10/2019.
//

import Foundation

/// The FileMessenger class runs all formatters in the order they were created and passes the resulting message
/// off to a file saved inside a given log directory. The FileMessenger manages a file roll with a given number of files and a maximum file size. It deletes files older than a given age or if files overflow the disk usage limit.
open class FileMessenger: LogFormatterMessenger {
    
    /// The path of directory where log files are saved
    public var logsDirectory: String {
        get { fileManager.logsDirectory }
    }
    
    /// The max number of files stored in logs directory
    public var maxFilesNumber: UInt {
        get { fileManager.maxFilesNumber }
    }
    
    #if os(iOS)
    /// The `FileProtectionType` attribute of log files.
    /// Default value is `FileProtectionType.completeUnlessOpen`, but if the app can run in background mode the default value is `FileProtectionType.completeUntilFirstUserAuthentication`.
    public var filesProtectionType: FileProtectionType {
        get { fileManager.filesProtectionType }
    }
    #endif
    
    /// The maximum size of a single log file.
    public var fileMaxSize: UInt64 {
        get { fileManager.fileMaxSize }
    }
    
    /// Files rolling frequency (in seconds). Files older than this value will be deleted.
    public var rollingFrequency: TimeInterval {
        get { fileManager.rollingFrequency }
    }
    
    /// Array of formatters that the messenger should execute (in order) on incoming messages.
    public var formatters: [LogFormatter]
    
    /// Current log file.
    public var currentFile: LogFile {
        get { fileManager.currentLogFile() }
    }
    
    /// A prefix used for the file name.
    public var filePrefix: String {
        get { fileManager.filePrefix }
    }
    
    // MARK: - Internal properties
    /// The file manager.
    internal var fileManager: LogFileManager
    
    // MARK: - Public functions
    public init(logsDirectory:String = FileMessenger.defaultLogsDirectory(),
                maxFilesNumber: UInt = 5,
                filesProtectionType: FileProtectionType? = nil,
                fileMaxSize: UInt64 = 1024*1024, // 1 MB
                rollingFrequency: TimeInterval = 60*60*24, // 24 Hours
                formatters: [LogFormatter] = [],
                filePrefix: String? = nil) {
        self.fileManager = LogFileManager(logsDirectory: logsDirectory,
                                          maxFilesNumber: maxFilesNumber,
                                          filesProtectionType: filesProtectionType,
                                          fileMaxSize: fileMaxSize,
                                          rollingFrequency: rollingFrequency,
                                          filePrefix: filePrefix)
        self.formatters = formatters
    }
    
    /// Dispatches the message to the file.
    ///
    /// Each formatter is run over the message in the order they are provided before dispatching the message.
    ///
    /// - Parameters:
    ///   - message:   The original message to write on file.
    ///   - logLevel:  The log level associated with the message.
    ///   - file: tha path of the file that calls this function.
    ///   - function: the name of the caller function.
    ///   - line: the line of code that calls this function.
    open func dispatchMessage(_ message: String,
                              logLevel: LogLevel,
                              file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        if let data = prepareMessageData(message,
                                         logLevel: logLevel,
                                         file: file,
                                         function: function,
                                         line: line) {
            fileManager.write(data)
        }
    }
    
    /// Dispatch the message to the file.
    ///
    /// Each formatter is run over the message in the order they are provided before dispatching the message.
    ///
    /// - Parameters:
    ///   - message:   The original message to write on file.
    ///   - logLevel:  The log level associated with the message.
    ///   - file: tha path of the file that calls this function.
    ///   - function: the name of the caller function.
    ///   - line: the line of code that calls this function.
    open func dispatchMessage(_ message: LogMessage,
                              logLevel: LogLevel,
                              file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        if let data = prepareMessageData("\(message.name): \(message.payload)",
            logLevel: logLevel,
            file: file, function:
            function,
            line: line) {
            fileManager.write(data)
        }
    }
    
    // MARK: - Internal functions
    
    /// Formats the message and extracts the `Data` to write on file.
    /// 
    /// - Parameters:
    ///   - message:   The original message to write on file.
    ///   - logLevel:  The log level associated with the message.
    ///   - file: tha path of the file that calls this function.
    ///   - function: the name of the caller function.
    ///   - line: the line of code that calls this function.
    internal func prepareMessageData(_ message: String,
                                     logLevel: LogLevel,
                                     file: StaticString, function: StaticString, line: UInt) -> Data? {
        var message = formatMessage(message, with: logLevel, file: file, function: function, line: line)
        if !message.hasSuffix("\n") {
            message.append("\n")
        }
        let data = message.data(using: .utf8)
        return data
    }

    
    // MARK: - Public Static functions
    public class func defaultLogsDirectory() -> String {
        return LogFileManager.defaultLogsDirectory()
    }
}

// MARK: - File Manager

internal class LogFileManager {
    
    /// The path of directory where log files are saved
    internal let logsDirectory: String
    
    /// The max number of files stored in logs directory
    internal let maxFilesNumber: UInt
    
    #if os(iOS)
    /// The `FileProtectionType` attribute of log files.
    /// Default value is `FileProtectionType.completeUnlessOpen`, but if the app can run in background mode the default value is `FileProtectionType.completeUntilFirstUserAuthentication`.
    internal let filesProtectionType: FileProtectionType
    #endif
    
    /// The maximum size of a single log file.
    internal let fileMaxSize: UInt64
    
    /// Files rolling frequency (in seconds). Files older than this value will be deleted.
    internal let rollingFrequency: TimeInterval
    
    /// The name of the application to assign to file names.
    internal static var applicationName: String = {
        if let id = Bundle.main.bundleIdentifier {
            return id
        }
        return ProcessInfo.processInfo.processName
    }()
    
    /// Date formatter for the file name
    internal lazy var logFileDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy'-'MM'-'dd' 'HH'-'mm'-'ss'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    /// The timer scheduled to rolling the current file when the rollingFrequency interval has passed.
    internal var rollingTimer: Timer?
    
    /// The prefix used for log files name.
    internal let filePrefix: String
    
    // MARK: - Private vars
    /// Reference to the LogFile currently active.
    private var _currentLogFile: LogFile?
    /// Reference to the current `FileHandle`
    private var _currentFileHandle: FileHandle?
    /// Reference to the current `DispatchSourceFileSystemObject` used to observe if the current file is deleted or renamed.
    private var _currentFileObserver: DispatchSourceFileSystemObject?
    /// The queue used to observe log files
    private let _handleQueue = DispatchQueue(label: "it.sysdata.blabber.file.handle",
                                            qos: .utility,
                                            attributes: [.concurrent],
                                            autoreleaseFrequency: .workItem,
                                            target: nil)
    
    // MARK: - Init & Deinit

    /// Creates a `LogFileManager` instance.
    ///
    /// - Parameter logsDirectory: The directory where log files are located. Default value is given by `defaultLogsDirectory()` class function.
    /// - Parameter maxFilesNumber: The maximum number of log files in the directory. Default value is 5.
    /// - Parameter filesProtectionType: The `FileProtectionType` attribute of log files.
    /// - Parameter fileMaxSize: The maximum size of a single log file. Default value is 1 MB.
    /// - Parameter rollingFrequency: Files rolling frequency (in seconds). Default value is 24 hours.
    internal init(logsDirectory:String = LogFileManager.defaultLogsDirectory(),
                  maxFilesNumber: UInt = 5,
                  filesProtectionType: FileProtectionType? = nil,
                  fileMaxSize: UInt64 = 1024*1025,
                  rollingFrequency: TimeInterval = 60*60*24,
                  filePrefix: String? = nil) {
        self.logsDirectory = logsDirectory
        self.maxFilesNumber = maxFilesNumber
        if let protection = filesProtectionType {
            self.filesProtectionType = protection
        } else {
            self.filesProtectionType = LogFileManager.appRunsInBackgroundMode() ? .completeUntilFirstUserAuthentication : .completeUnlessOpen
        }
        self.fileMaxSize = fileMaxSize
        self.rollingFrequency = rollingFrequency
        self.filePrefix = filePrefix ?? LogFileManager.applicationName
    }
    
    
    /// Before deinitialization, it synchronized and closes the current file, cancels the file observer
    /// and invalidates the rolling timer.
    deinit {
        _currentFileHandle?.synchronizeFile()
        _currentFileHandle?.closeFile()
        
        _currentFileObserver?.cancel()
        
        rollingTimer?.invalidate()
    }
    
    // MARK: - Write

    /// Writes the data in current file
    ///
    /// - Parameter data: Data to write
    internal func write(_ data: Data) {
        currentFileHandle()?.write(data)
        let _ = rollFileDueToSize()
    }
    
    // MARK: - Creation
    
    /// Creates the name for a new log file with a given date.
    /// - Parameter date: The date that will be part of the new log file name.
    internal func newLogFileName(with date: Date) -> String {
        let prefix = self.filePrefix
        let date = logFileDateFormatter.string(from: date)
        return "\(prefix) \(date).log"
    }
    
    internal func createLogsDirectoryIfNeeded() throws {
        if !FileManager.default.fileExists(atPath: logsDirectory) {
            try FileManager.default.createDirectory(atPath: logsDirectory,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        }
    }
    
    
    /// Creates a new `LogFile`, creating the logs directory and the file if they don't exist yet.
    internal func createNewLogFile() -> LogFile {
        let fileName = newLogFileName(with: Date())
        let filePath = URL(fileURLWithPath: logsDirectory).appendingPathComponent(fileName).path
        
        // Checks if file already exists
        if !FileManager.default.fileExists(atPath: filePath) {
            // Prepares attributes depending on OS
            #if os(iOS)
            let attributes: [FileAttributeKey: Any] = [.protectionKey: filesProtectionType]
            #else
            let attributes: [FileAttributeKey: Any] = [:]
            #endif
            
            // Creates the directory
            try! createLogsDirectoryIfNeeded()
            // Creates the new file
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: attributes)
            
            // Deletes old log files if the number of files is greater than maxFilesNumber
            deleteOldFilesDueToNumber()
        }
        
        return LogFile(with: filePath)
    }
    
    // MARK: - Deletion
    
    /// Deletes old files if the number is greater than `maxFilesNumber`
    internal func deleteOldFilesDueToNumber() {
        var logFiles = logFileInfos()
        
        if logFiles.count > maxFilesNumber {
            repeat {
                if let file = logFiles.first {
                    try? FileManager.default.removeItem(atPath: file.filePath)
                }
                logFiles = logFileInfos()
            } while logFiles.count > maxFilesNumber
        }
    }
    
    // MARK: - Current File

    /// Prepares and returns the current `LogFile`
    internal func currentLogFile() -> LogFile {
        // It has already an active file
        if let file = _currentLogFile {
            return file
        }
        
        // Retrieves saved files to find the most recent.
        let logFiles = logFileInfos()
        if let mostRecentFile = logFiles.last {
            var isFileReusable = true
            
            // Checks if the most recent file respects the `fileMaxSize` rule.
            if !isFileReusableDueToSize(file: mostRecentFile) {
                isFileReusable = false
            }
            
            // Checks if the most recent file respects the `rollingFrequency` rule.
            if !isFileReusableDueToAge(file: mostRecentFile) {
                isFileReusable = false
            }
            
            // Checks if the most recent file is accessible.
            if !isFileReusableDueToAccessibility(file: mostRecentFile) {
                isFileReusable = false
            }
            
            // If the file is reusable, returns it.
            if isFileReusable {
                _currentLogFile = mostRecentFile
                return mostRecentFile
            }
        }
        
        // There is not any reusable file, it creates a new one.
        let newFile = createNewLogFile()
        _currentLogFile = newFile
        return newFile
    }
    
    
    /// Checks if the log file is too big.
    ///
    /// - Parameter file: The `LogFile` to check.
    internal func isFileReusableDueToSize(file: LogFile) -> Bool {
        if fileMaxSize > 0, file.fileSize >= fileMaxSize {
            // The file is too big
            return false
        }
        return true
    }
    
    /// Checks if the log file is too old.
    ///
    /// - Parameter file: The `LogFile` to check.
    internal func isFileReusableDueToAge(file: LogFile) -> Bool {
        if rollingFrequency > 0, file.age >= rollingFrequency {
            // The most recent file is too old
            return false
        }
        return true
    }
    
    /// Checks if the log file is accessible.
    ///
    /// - Parameter file: The `LogFile` to check.
    internal func isFileReusableDueToAccessibility(file: LogFile) -> Bool {
        #if os(iOS)
        // If the app can run in background, the file's protection must be `completeUntilFirstUserAuthentication`
        // or `none` to be sure that the file is always accessible.
        if LogFileManager.appRunsInBackgroundMode() {
            if file.protectionType != .completeUntilFirstUserAuthentication && file.protectionType != .none {
                 return false
            }
        }
        #endif
        return true
    }
    
    /// Prepares and returns the `FileHandle` for the current file.
    internal func currentFileHandle() -> FileHandle? {
        // It has already an active file handle
        if let handle = _currentFileHandle {
            return handle
        }
        
        // Creates a new FileHandle for the current file and sets it to the end of file.
        _currentFileHandle = FileHandle(forWritingAtPath: currentLogFile().filePath)
        _currentFileHandle?.seekToEndOfFile()
        
        // Preparing the file observer
        let _ = currentFileObserver()
        
        // Scheduling the timer
        let _ = scheduleFileRollingTimer()
        
        return _currentFileHandle
    }
    
    /// Prepares and returns the `DispatchSourceFileSystemObject` to observe the current file.
    internal func currentFileObserver() -> DispatchSourceFileSystemObject? {
        guard let handle = _currentFileHandle else { return nil }
        
        // Creates a new observer for file deletion or renaming
        _currentFileObserver = DispatchSource.makeFileSystemObjectSource(fileDescriptor: handle.fileDescriptor,
                                                                         eventMask: [.delete, .rename],
                                                                         queue: _handleQueue)
        _currentFileObserver?.setEventHandler(handler: { [weak self] in
            self?.rollLogFile()
        })
        
        _currentFileObserver?.resume()
        
        return _currentFileObserver
    }
    
    
    
    // MARK: - File rolling
    
    /// Rolls the current file.
    internal func rollLogFile() {
        guard let handle = _currentFileHandle else { return }
        
        // Synchronizing and closing the file
        handle.synchronizeFile()
        handle.closeFile()
        
        // Removing any reference to the file
        _currentFileHandle = nil
        _currentLogFile = nil
        
        // Blocking the observer
        _currentFileObserver?.cancel()
        _currentFileObserver = nil
    }
    
    /// Schedules the rolling timer for the current file.
    internal func scheduleFileRollingTimer() -> Timer? {
        // eventually invalidates the current timer
        rollingTimer?.invalidate()
        rollingTimer = nil
        
        // Checking preconditions
        guard let creationDate = _currentLogFile?.creationDate, rollingFrequency > 0 else { return nil }
        let time = rollingFrequency - creationDate.timeIntervalSinceNow
        
        // Creating the timer
        rollingTimer = Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { [weak self] timer in
            let _ = self?.rollFileDueToAge()
        })
        
        return rollingTimer
    }
    
    /// Checks if the current file has to be rolled due to age.
    /// If the file is not too old, reschedules the rolling timer, otherwise rolls it.
    internal func rollFileDueToAge() -> Bool {
        guard let age = _currentLogFile?.age, rollingFrequency > 0 else { return false }
        
        if age > rollingFrequency {
            rollLogFile()
            return true
        } else {
            let _ = scheduleFileRollingTimer()
            return false
        }
    }
    
    /// Checks if the current file has to be rolled due to size.
    /// If the file is too big, then rolls it.
    internal func rollFileDueToSize() -> Bool {
        guard fileMaxSize > 0, let handle = _currentFileHandle else { return false }
        
        let size = handle.offsetInFile
        if size >= fileMaxSize {
            rollLogFile()
            return true
        }
        return false
    }
    
    // MARK: - Log Files
    
    /// Retrieves all `LogFile`s stored in logs directory, sorted by age.
    internal func logFileInfos() -> [LogFile] {
        do {
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: logsDirectory)
            let filePaths = fileNames.map { URL(fileURLWithPath: logsDirectory).appendingPathComponent($0).path }
            var fileInfos = filePaths.map { LogFile(with: $0) }
            fileInfos.sort { $0.age >= $1.age }
            return fileInfos
        } catch {
            return []
        }
    }
    
    // MARK: - Internal Static functions
    
    /// Checks if the app has any background mode entitlement
    internal class func appRunsInBackgroundMode() -> Bool {
        // looking for background mode keys in Info.plist
        guard let backgroundModes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? Array<String> else {
            return false
        }
        // if there is a key, then return true
        for mode in backgroundModes {
            if mode.count > 0 {
                return true
            }
        }
        return false
    }
    
    
    /// Returns the default path of the log directory.
    /// sThe path depends on the operating system.
    internal class func defaultLogsDirectory() -> String {
        #if os(iOS)
        let directory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
            let directoryUrl = URL(fileURLWithPath: directory ?? NSTemporaryDirectory())
            let logsUrl = directoryUrl.appendingPathComponent("Logs")
            return logsUrl.path
        #else
            let appName = ProcessInfo.processInfo.processName
            let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
            let directory = paths.first ?? NSTemporaryDirectory()
            let directoryUrl = URL(fileURLWithPath: directory)
            let logsUrl = directoryUrl.appendingPathComponent("Logs").appendingPathComponent(appName)
            return logsUrl.path
        #endif
    }
}

public class LogFile: CustomStringConvertible {
    
    /// The path of the log file.
    public let filePath: String
    
    
    /// File attributes where keys are `FileAttributeKey`.
    public var fileAttributes: [FileAttributeKey: Any] {
        get {
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: filePath) else {
                return [:]
            }
            return attributes
        }
    }
    
    
    /// The name of the file
    public var fileName: String {
        get { URL(fileURLWithPath: filePath).lastPathComponent }
    }
    
    
    /// The modification date attribute value.
    public var modificationDate: Date? {
        get { fileAttributes[FileAttributeKey.modificationDate] as? Date }
    }
    
    /// The creation date attribute value.
    public var creationDate: Date? {
        get { fileAttributes[FileAttributeKey.creationDate] as? Date }
    }
    
    /// The size attribute value.
    public var fileSize: UInt64 {
        get { (fileAttributes[FileAttributeKey.size] as? UInt64) ?? 0 }
    }
    
    /// The time (in seconds) passed since the creation date.
    public var age: TimeInterval {
        get {
            guard let creationDate = creationDate else {
                return 0
            }
            return creationDate.timeIntervalSinceNow * -1 // to return a positive value
        }
    }
    
    /// The protection type attribute value.
    public var protectionType: FileProtectionType {
        get { (fileAttributes[FileAttributeKey.protectionKey] as? FileProtectionType) ?? .none }
    }
    
    /// Creates an instance of `LogFile` with a file path
    ///
    /// - Parameter path: the path of the new file.
    internal init(with path: String) {
        self.filePath = path
    }
    
    // MARK: - CustomStringConvertible
    /// Returns a `String` representation of the `LogFile`.
    public var description: String {
        return ["path": filePath,
                "name": fileName,
                "attributes": fileAttributes,
                "creationDate": (creationDate != nil ? dateFormatter.string(from: creationDate!) : ""),
                "modificationDate": (modificationDate != nil ? dateFormatter.string(from: modificationDate!) : ""),
                "size": fileSize,
                "age": age]
            .description
    }
    
    /// The date formatter used for the description.
    private lazy var dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "'yyyy'-'MM'-'dd' 'HH':'ss'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
