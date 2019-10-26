# Haikoo

<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
<img alt="License" src="https://img.shields.io/badge/License-MIT-lightgrey">
<img alt="Platforms" src="https://img.shields.io/badge/platform-ios%20%7C%20osx-lightgrey">
<img alt="Coverage" src="https://img.shields.io/badge/coverage-95%25-green">
A description of this package.

## Features

- [x] Synchronous & asynchronous logging.
- [x] Console loggins.
- [x] OSLog loggins.
- [x] File logging, with size and age rolling.
- [x] Long messages truncation.
- [x] Multiple and customizable log levels.
- [x] Extensible formatters and loggers.

## Requirements
iOS 10 and above, MacOS 10.12 and above.

## Installation

Haikoo is available through Swift Package Manager.

## Introduction
Haikoo is an extensible and light-weight logging library with different log levels.

It can log with a synchronous dispatch method, useful during the development, and an asynchronous one for better performances in production. 

A Haikoo instance can log in console using print and os_log and on file, but you can extend it with new destinations.

## Initialization
The simplest way to initialize a Haikoo is to instantiate a `LogMessenger` and a `LogFormatter` at least.

```
let formatter = CompleteFormatter(symbols: "🔱🔱🔱")

let consoleMessenger = ConsoleMessenger(formatters: [formatter])

```

Then you can instantiate your `Haikoo` instance.

```
let Haikoo = Haikoo(logLevels: .all, messengers: [consoleMessenger])

Haikoo.verbose("Your message")

Haikoo.debug("Your message")

Haikoo.info("Your message")

Haikoo.warning("Your message")

Haikoo.error("Your message")

Haikoo.fatal("Your message")

```

## Log Levels
LogLevel is an OptionSet. Haikoo defines six log levels with values from `1<<0` to `1<<5`. You can use values from `1<<6` to `1<<31` to define you custom log levels.

You can instantiate your Haikoo with the `.all` level to log messages with all log levels.

Set the `enabled` flag to false to stop your Haikoo.

## Log Formatters
A Log Formatter defines the way to modify the message before the messenger dispatches it.

Every `LogMessenger` is initialized with a list of formatters.

Haikoo provides following formatters:

- `TimestampFormatter`, that applies a timestamp to the beginning of the message.
- `SymbolsFormatter`, that applies emojies to the beginning of the message.
- `FunctionFormatter`, applies filename, function and line of the caller at the end of the message.
- `CompleteFormatter`, that works as the three formatters above together.

To create a custom log formatter, it must conform to `LogFormatter` protocol.

## Log Messengers
A Log Messenger dispatches messages to their final destination.

Every Haikoo instance takes a list of messengers in input.

Haikoo provides following messengers:

- `ConsoleMessenger`, that dispatches messages to the console, using print.
- `OSLogMessenger`, that dispatches messages to the console using os_log.
- `FileMessenger`, that writes logs on files.

To create a custom messenger, it must conform to `LogMessenger` protocol, or to `LogFormatterMessenger` if you want to use formatters.

### ConsoleMessenger
It writes your log in console using `print()` function.

You can set a `maxMessageLength` to truncate long messages.

### OSLogMessenger
An OSLogMessenger instance takes in input a subsystem and a category, that you can use to filter logs using the Console.app.

You can set a `maxMessageLength` to truncate long messages.

### FileMessenger
FileMessenger provides a number of properties to set up file logs:

- `logsDirectory` to define a custom logs directory. On iOS the default directory is `Library/Cache/Logs`.
- `maxFilesNumber`, when files count goes above this number, the messenger deletes the oldest file.
- `filesProtectionType`, useful on iOS to protect log files with automatic encryption and decryption.
- `fileMaxSize`, the maximum size of a single file.
- `rollingFrequency`, the maximum age of a file. Files older than this value will be deleted.
- `filePrefix`, a custom prefix used for a file name.

