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
      guard let animation = Samples.animation(named: sampleAnimationName) else { continue }

      var compatibilityIssues = [CompatibilityIssue]()

      let animationLayer = CoreAnimationLayer(
        animation: animation,
        imageProvider: BundleImageProvider(bundle: Bundle.main, searchPath: nil),
        fontProvider: DefaultFontProvider(),
        compatibilityTrackerMode: .track,
        didSetUpAnimation: { issues in
          compatibilityIssues = issues
        })

      animationLayer.bounds = CGRect(origin: .zero, size: animation.size)
      animationLayer.layoutIfNeeded()
      animationLayer.display()

      let compatibilityReport: String
      if compatibilityIssues.isEmpty {
        compatibilityReport = "Supports Core Animation engine"
      } else {
        compatibilityReport = (
          ["Does not support Core Animation engine. Encountered compatibility issues:"]
            + compatibilityIssues.map { $0.description })
          .joined(separator: "\n")
      }

      assertSnapshot(
        matching: compatibilityReport,
        as: .description,
        named: sampleAnimationName)
    }
  }

  override func setUp() {
    LottieLogger.shared = .printToConsole
  }

  override func tearDown() {
    LottieLogger.shared = LottieLogger()
  }

}
