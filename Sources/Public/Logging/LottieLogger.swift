// Created by eric_horacek on 12/9/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// MARK: - LottieLogger

/// A shared logger that allows consumers to intercept Lottie assertions and warning messages to pipe
/// into their own logging systems.
public final class LottieLogger {

  // MARK: Lifecycle

  public init(
    assert: @escaping Assert = Swift.assert,
    assertionFailure: @escaping AssertionFailure = Swift.assertionFailure,
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

  /// The shared instance used to log Lottie assertions and warnings.
  ///
  /// Set this to a new logger instance to intercept assertions and warnings logged by Lottie.
  public static var shared = LottieLogger()

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

// MARK: - LottieLogger + printToConsole

extension LottieLogger {
  /// A `LottieLogger` instance that always prints to the console (by calling `print`)
  /// instead of calling `assert` / `assertionFailure`, which halt execution in debug builds.
  public static var printToConsole: LottieLogger {
    LottieLogger(
      assert: { condition, message, _, _ in
        if !condition() {
          print(message())
        }
      },
      assertionFailure: { message, _, _ in
        print(message())
      })
  }
}
