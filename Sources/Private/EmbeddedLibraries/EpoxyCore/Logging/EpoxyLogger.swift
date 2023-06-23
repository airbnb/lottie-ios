// Created by eric_horacek on 12/9/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

/// A shared logger that allows consumers to intercept Epoxy assertions and warning messages to pipe
/// into their own logging systems.
public final class EpoxyLogger {

  // MARK: Lifecycle

  public init(
    assert: @escaping Assert = { condition, message, file, line in
      // If we default to `Swift.assert` directly with `assert: Assert = Swift.assert`,
      // the call will unexpectedly not respect the -O flag and will crash in release
      // https://github.com/apple/swift/issues/60249
      Swift.assert(condition(), message(), file: file, line: line)
    },
    assertionFailure: @escaping AssertionFailure = { message, file, line in
      // If we default to `Swift.assertionFailure` directly with
      // `assertionFailure: AssertionFailure = Swift.assertionFailure`,
      // the call will unexpectedly not respect the -O flag and will crash in release
      // https://github.com/apple/swift/issues/60249
      Swift.assertionFailure(message(), file: file, line: line)
    },
    warn: @escaping Warn = { message, _, _ in
      #if DEBUG
      // swiftlint:disable:next no_direct_standard_out_logs
      print(message())
      #endif
    })
  {
    _assert = assert
    _assertionFailure = assertionFailure
    _warn = warn
  }

  // MARK: Public

  /// Logs that an assertion occurred.
  public typealias Assert = (
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String,
    _ fileID: StaticString,
    _ line: UInt)
    -> Void

  /// Logs that an assertion failure occurred.
  public typealias AssertionFailure = (
    _ message: @autoclosure () -> String,
    _ fileID: StaticString,
    _ line: UInt)
    -> Void

  /// Logs a warning message.
  public typealias Warn = (
    _ message: @autoclosure () -> String,
    _ fileID: StaticString,
    _ line: UInt)
    -> Void

  /// The shared instance used to log Epoxy assertions and warnings.
  ///
  /// Set this to a new logger instance to intercept assertions and warnings logged by Epoxy.
  public static var shared = EpoxyLogger()

  /// Logs that an assertion occurred.
  public func assert(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = String(),
    fileID: StaticString = #fileID,
    line: UInt = #line)
  {
    _assert(condition(), message(), fileID, line)
  }

  /// Logs that an assertion failure occurred.
  public func assertionFailure(
    _ message: @autoclosure () -> String = String(),
    fileID: StaticString = #fileID,
    line: UInt = #line)
  {
    _assertionFailure(message(), fileID, line)
  }

  /// Logs a warning message.
  public func warn(
    _ message: @autoclosure () -> String = String(),
    fileID: StaticString = #fileID,
    line: UInt = #line)
  {
    _warn(message(), fileID, line)
  }

  // MARK: Private

  private let _assert: Assert
  private let _assertionFailure: AssertionFailure
  private let _warn: Warn

}
