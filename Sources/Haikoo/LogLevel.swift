//
//  LogLevel.swift
//  Haikoo
//
//  Created by Paolo Ardia on 13/10/2019.
//

import Foundation

/// The `LogLevel` struct defines all the default log levels for Haikoo. Each default log level has a defined bitmask that is used to satisfy the raw value backing the log level. The empty bits that remain allow custom log levels.
public struct LogLevel: OptionSet, Equatable, Hashable {

    // MARK: Properties

    /// Defines the RawValue type as a UInt.
    public typealias RawValue = UInt

    /// Returns the raw bitmask value of the LogLevel and satisfies the `RawRepresentable` protocol.
    public let rawValue: RawValue

    private static let offBitmask       : RawValue = 0b00000000_00000000_00000000_00000000 // 0
    private static let verboseBitmask   : RawValue = 0b00000000_00000000_00000000_00000001 // (1 << 0)
    private static let debugBitmask     : RawValue = 0b00000000_00000000_00000000_00000010 // (1 << 1)
    private static let infoBitmask      : RawValue = 0b00000000_00000000_00000000_00000100 // (1 << 2)
    private static let warningBitmask   : RawValue = 0b00000000_00000000_00000000_00001000 // (1 << 3)
    private static let errorBitmask     : RawValue = 0b00000000_00000000_00000000_00010000 // (1 << 4)
    private static let fatalBitmask     : RawValue = 0b00000000_00000000_00000000_00100000 // (1 << 5)
    private static let allBitmask       : RawValue = 0b11111111_11111111_11111111_11111111

    /// Creates a new default `.off` instance with a bitmask where all bits are equal to 0.
    public static let off = LogLevel(rawValue: offBitmask)
    /// Creates a new default `.off` instance with a bitmask where all bits are equal to 0.
    public static let shutUp = off

    /// Creates a new default `.verbose` instance with a bitmask of `1`.
    public static let verbose = LogLevel(rawValue: verboseBitmask)

    /// Creates a new default `.debug` instance with a bitmask of `1 << 1`.
    public static let debug = LogLevel(rawValue: debugBitmask)

    /// Creates a new default `.info` instance with a bitmask of `1 << 2`.
    public static let info = LogLevel(rawValue: infoBitmask)

    /// Creates a new default `.warning` instance with a bitmask of `1 << 3`.
    public static let warning = LogLevel(rawValue: warningBitmask)

    /// Creates a new default `.error` instance with a bitmask of `1 << 4`.
    public static let error = LogLevel(rawValue: errorBitmask)
    
    /// Creates a new default `.fatal` instance with a bitmask of `1 << 5`.
    public static let fatal = LogLevel(rawValue: fatalBitmask)

    /// Creates a new default `.all` instance with a bitmask where all bits equal are equal to `1`.
    public static let all = LogLevel(rawValue: allBitmask)
    /// Creates a new default `.all` instance with a bitmask where all bits equal are equal to `1`.
    public static let logorrhoea = all

    // MARK: Initialization Methods

    /// Creates a log level instance with the given raw value.
    ///
    /// - Parameter rawValue: The raw bitmask value for the log level.
    ///
    /// - Returns: A new log level instance.
    public init(rawValue: RawValue) { self.rawValue = rawValue }
}

// MARK: - CustomStringConvertible

extension LogLevel: CustomStringConvertible {
    /// Returns a `String` representation of the `LogLevel`.
    public var description: String {
        switch self {
        case LogLevel.off:
            return "Off"
        case LogLevel.verbose:
            return "Verbose"
        case LogLevel.debug:
            return "Debug"
        case LogLevel.info:
            return "Info"
        case LogLevel.warning:
            return "Warning"
        case LogLevel.error:
            return "Error"
        case LogLevel.fatal:
            return "Fatal"
        case LogLevel.all:
            return "All"
        default:
            return "Unknown"
        }
    }
}
