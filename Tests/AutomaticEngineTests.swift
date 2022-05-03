// Created by Cal Stephens on 5/2/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SnapshotTesting
import UIKit
import XCTest

@testable import Lottie

final class AutomaticEngineTests: XCTestCase {

  /// Snapshot test for the result of `animation.supportedByCoreAnimationEngine`
  func testAutomaticEngineDetection() throws {
    for sampleAnimationName in Samples.sampleAnimationNames {
      guard
        let animation = SnapshotConfiguration.makeAnimationView(
          for: sampleAnimationName,
          configuration: .init(renderingEngine: .coreAnimation))?.animation
      else { continue }

      assertSnapshot(
        matching: animation.supportedByCoreAnimationEngine
          ? "Supports Core Animation engine"
          : "Does not support Core Animation engine",
        as: .description,
        named: sampleAnimationName)
    }
  }

}
