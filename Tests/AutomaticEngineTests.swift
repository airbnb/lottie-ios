// Created by Cal Stephens on 5/2/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SnapshotTesting
import UIKit
import XCTest

@testable import Lottie

@MainActor
final class AutomaticEngineTests: XCTestCase {

  /// Snapshot tests for whether or not each sample animation supports the Core Animation engine
  func testAutomaticEngineDetection() async throws {
    for sampleAnimationName in Samples.sampleAnimationNames {
      var animation = Samples.animation(named: sampleAnimationName)
      if animation == nil {
        animation = await Samples.dotLottie(named: sampleAnimationName)?.animations.first?.animation
      }

      guard let animation = animation else {
        XCTFail("Couldn't load animation named \(sampleAnimationName)")
        continue
      }

      var compatibilityIssues = [CompatibilityIssue]()

      let animationLayer = try XCTUnwrap(CoreAnimationLayer(
        animation: animation,
        imageProvider: BundleImageProvider(bundle: Bundle.main, searchPath: nil),
        textProvider: DefaultTextProvider(),
        fontProvider: DefaultFontProvider(),
        compatibilityTrackerMode: .track,
        logger: .shared))

      animationLayer.didSetUpAnimation = { issues in
        compatibilityIssues = issues
      }

      animationLayer.bounds = CGRect(origin: .zero, size: animation.size)
      animationLayer.layoutIfNeeded()
      animationLayer.display()

      let compatibilityReport: String
      if compatibilityIssues.isEmpty {
        compatibilityReport = "Supports Core Animation engine"
      } else {
        compatibilityReport = "Does not support Core Animation engine. Encountered compatibility issues:\n"
          + compatibilityIssues.map { $0.description }.joined(separator: "\n")
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
