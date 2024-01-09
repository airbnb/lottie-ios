// Created by Cal Stephens on 9/19/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import SnapshotTesting
import UIKit
import XCTest

@testable import Lottie

// MARK: - LoggingTests

@MainActor
final class LoggingTests: XCTestCase {

  // MARK: Internal

  func testAnimationWithNoIssues() async {
    await snapshotLoggedMessages(
      animationName: "LottieLogo1",
      configuration: LottieConfiguration(renderingEngine: .automatic))
  }

  func testAutomaticFallbackToMainThreadRenderingEngine() async {
    // This animation is not supported by the Core Animation rendering engine:
    //  > The Core Animation rendering engine does not support animating multiple keyframes
    //  > for stroke dashPattern values, due to limitations of Core Animation.
    await snapshotLoggedMessages(
      animationName: "TypeFace/G",
      configuration: LottieConfiguration(renderingEngine: .automatic))
  }

  func testCoreAnimationRenderingEngineUnsupportedAnimation() async {
    // This animation is not supported by the Core Animation rendering engine:
    //  > The Core Animation rendering engine does not support animating multiple keyframes
    //  > for stroke dashPattern values, due to limitations of Core Animation.
    await snapshotLoggedMessages(
      animationName: "TypeFace/G",
      configuration: LottieConfiguration(renderingEngine: .coreAnimation))
  }

  func testExplicitMainThreadRenderingEngine() async {
    // This animation is not supported by the Core Animation rendering engine.
    // Manually specifying the Main Thread rendering engine should silence the log messages.
    await snapshotLoggedMessages(
      animationName: "TypeFace/G",
      configuration: LottieConfiguration(renderingEngine: .mainThread))
  }

  func testUnsupportedAfterEffectsExpressionsWarning() async {
    // This animation has unsupported After Effects expressions, which triggers a log message
    await snapshotLoggedMessages(
      animationName: "LottieFiles/growth",
      configuration: LottieConfiguration(renderingEngine: .automatic))
  }

  // MARK: Private

  private func snapshotLoggedMessages(
    animationName: String,
    configuration: LottieConfiguration,
    function: String = #function,
    line: UInt = #line)
    async
  {
    let loggedMessages = await loggedMessages(for: animationName, configuration: configuration)

    assertSnapshot(
      matching: loggedMessages.joined(separator: "\n"),
      as: .description,
      named: animationName,
      testName: function,
      line: line)
  }

  private func loggedMessages(for animationName: String, configuration: LottieConfiguration) async -> [String] {
    var logMessages = [String]()

    let logger = LottieLogger(
      assert: { condition, message, _, _ in
        if !condition() {
          logMessages.append("[assertionFailure] \(message())")
        }
      },
      assertionFailure: { message, _, _ in
        logMessages.append("[assertionFailure] \(message())")
      },
      warn: { message, _, _ in
        logMessages.append("[warning] \(message())")
      },
      info: { message in
        logMessages.append("[info] \(message())")
      })

    let animationView = await SnapshotConfiguration.makeAnimationView(
      for: animationName,
      configuration: configuration,
      logger: logger)!

    animationView.renderContentsForUnitTests()

    if logMessages.isEmpty {
      return ["Animation setup did not emit any logs"]
    }

    return logMessages
  }
}
