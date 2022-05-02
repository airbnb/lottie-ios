// Created by Cal Stephens on 5/2/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import UIKit
import XCTest

import SnapshotTesting
@testable import Lottie

final class AutomaticEngineTests: XCTestCase {

  /// Checks that the result of `animation.supportedByCoreAnimationEngine`
  /// matches whether or not an assertion is emitted when rendering the animation
  /// using the Core Animation engine
  func testAutomaticEngineDetection() {
    // While this feature is still in development, we disable assertions
    // for this test case to keep CI green. TODO: Enable assertions in CI.
    let emitXCTAssertions = false

    for sampleAnimationName in Samples.sampleAnimationNames {
      var logs = [String]()

      LottieLogger.shared = .init(
        assert: { condition, message, _, _ in
          if !condition() {
            logs.append(message())
          }
        },
        assertionFailure: { message, _, _ in
          logs.append(message())
        },
        warn: { message, _, _ in
          logs.append(message())
        })

      guard
        let (animation, animationView) = SnapshotConfiguration.makeAnimationView(
          for: sampleAnimationName,
          configuration: .init(renderingEngine: .coreAnimation))
      else { continue }

      animationView.frame = CGRect(origin: .zero, size: animation.size)
      animationView.layoutIfNeeded()
      animationView.currentProgress = 0.5

      let supportsCoreAnimationEngine = animation.supportedByCoreAnimationEngine

      if emitXCTAssertions {
        if supportsCoreAnimationEngine {
          XCTAssert(logs.isEmpty, """
            Unexpected assertions / logs for animation "\(sampleAnimationName)":
            \(logs)
            """)
        } else {
          XCTAssert(!logs.isEmpty, """
            Animation "\(sampleAnimationName)" is listed as not supporting the Core Animation engine,
            but no assertions were emitted when rendering it.
            """)
        }
      }

      assertSnapshot(
        matching: supportsCoreAnimationEngine
          ? "Supports Core Animation engine"
          : "Does not support Core Animation engine",
        as: .description,
        named: sampleAnimationName)
    }
  }

}
