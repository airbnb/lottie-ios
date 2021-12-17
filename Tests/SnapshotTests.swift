// Created by Cal Stephens on 12/8/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import SnapshotTesting
import XCTest

#if canImport(UIKit)
import UIKit
#endif

@testable import Lottie

// MARK: - SnapshotTests

class SnapshotTests: XCTestCase {

  // MARK: Internal

  /// Snapshots all of the sample animation JSON files visible to this test target
  func testLottieSnapshots() throws {
    try compareSampleSnapshots()
  }

  /// Snapshots sample animation files using the experimental rendering engine
  ///  - TODO: We should have a snapshots that test both:
  ///     1. the `CAKeyframeAnimation`s (which can only be snapshot through `CALayer.presentation()`)
  ///     2. interactively setting `animationView.currentProgress` (which interpolates manually)
  ///  - This currently only tests (2), which isn't set up for the experimental rendering engine yet.
  func testExperimentalRenderingEngine() throws {
    try compareSampleSnapshots(usingExperimentalRenderingEngine: true)
  }

  /// Validates that all of the snapshots in __Snapshots__ correspond to
  /// a sample JSON file that is visible to this test target.
  func testAllSnapshotsHaveCorrespondingSampleFile() {
    for snapshotURL in snapshotURLs {
      // The snapshot files follow the format `testLottieSnapshots.NAME-PERCENTAGE.png`
      let animationName = snapshotURL.lastPathComponent.components(separatedBy: .init(charactersIn: ".-"))[1]

      XCTAssert(
        sampleAnimationURLs.contains(where: { $0.lastPathComponent == "\(animationName).json" }),
        "Snapshot \"\(snapshotURL.lastPathComponent)\" has no corresponding sample animation")
    }
  }

  /// Validates that all of the custom snapshot configurations in `SnapshotConfiguration.customMapping`
  /// reference a sample json file that actually exists
  func testCustomSnapshotConfigurationsHaveCorrespondingSampleFile() {
    for (animationName, _) in SnapshotConfiguration.customMapping {
      XCTAssert(
        sampleAnimationURLs.contains(where: { $0.lastPathComponent == "\(animationName).json" }),
        "Custom configuration for \"\(animationName)\" has no corresponding sample animation")
    }
  }

  /// Validates that this test target can access sample json files from `Tests/Samples`
  /// and snapshot images from `Tests/__Snapshots__`.
  func testCanAccessSamplesAndSnapshots() {
    XCTAssert(sampleAnimationURLs.count > 50)
    XCTAssert(snapshotURLs.count > 300)
  }

  // MARK: Private

  /// The list of sample animation files in `Tests/Samples`
  private let sampleAnimationURLs = Bundle.module.urls(forResourcesWithExtension: "json", subdirectory: nil)!

  /// The list of snapshot image files in `Tests/__Snapshots__`
  private let snapshotURLs = Bundle.module.urls(forResourcesWithExtension: "png", subdirectory: nil)!

  /// Captures snapshots of `sampleAnimationURLs` and compares them to the snapshot images stored on disk
  private func compareSampleSnapshots(
    usingExperimentalRenderingEngine: Bool = false,
    testName: String = #function) throws
  {
    #if os(iOS)
    guard UIScreen.main.scale == 2 else {
      /// Snapshots are captured at a 2x scale, so we can only support
      /// running tests on a device that has a 2x scale.
      ///  - In CI we run tests on an iPhone 8 simulator,
      ///    but any device with a 2x scale works.
      throw SnapshotError.unsupportedDevice
    }

    for sampleAnimationURL in sampleAnimationURLs {
      let sampleAnimationName = sampleAnimationURL.lastPathComponent.replacingOccurrences(of: ".json", with: "")
      let configuration = SnapshotConfiguration.forSample(named: sampleAnimationName)

      if usingExperimentalRenderingEngine, !configuration.testWithExperimentalRenderingEngine {
        continue
      }

      guard let animation = Animation.named(sampleAnimationName, bundle: .module) else {
        XCTFail("Could not parse \(sampleAnimationName).json")
        continue
      }

      for percent in [0, 0.25, 0.5, 0.75, 1.0] {
        let animationView = AnimationView(
          animation: animation,
          _experimentalFeatureConfiguration: ExperimentalFeatureConfiguration(
            useNewRenderingEngine: usingExperimentalRenderingEngine))

        // Set up the animation view with a valid frame and layout
        // so the geometry is correct when setting up the `CAAnimation`s
        animationView.frame.size = animation.snapshotSize
        animationView.layoutIfNeeded()

        animationView.currentProgress = CGFloat(percent)

        assertSnapshot(
          matching: animationView,
          as: .imageOfPresentationLayer(precision: configuration.precision),
          named: "\(sampleAnimationName) (\(Int(percent * 100))%)",
          testName: testName)
      }
    }
    #else
    // We only run snapshot tests on iOS, since running snapshot tests
    // for macOS and tvOS would triple the number of snapshot images
    // we have to check in to the repo.
    throw SnapshotError.unsupportedPlatform
    #endif
  }

}

// MARK: Animation + snapshotSize

extension Animation {
  /// The size that this animation should be snapshot at
  fileprivate var snapshotSize: CGSize {
    let maxDimension: CGFloat = 500

    // If this is a landscape aspect ratio, we clamp the width
    if width > height {
      let newWidth = min(CGFloat(width), maxDimension)
      let newHeight = newWidth * (CGFloat(height) / CGFloat(width))
      return CGSize(width: newWidth, height: newHeight)
    }

    // otherwise, this is either a square or portrait aspect ratio,
    // in which case we clamp the height
    else {
      let newHeight = min(CGFloat(height), maxDimension)
      let newWidth = newHeight * (CGFloat(width) / CGFloat(height))
      return CGSize(width: newWidth, height: newHeight)
    }
  }
}

// MARK: - SnapshotError

enum SnapshotError: Error {
  /// We only run snapshot tests on iOS, since running snapshot tests
  /// for macOS and tvOS would triple the number of snapshot images
  /// we have to check in to the repo.
  case unsupportedPlatform

  /// Snapshots are captured at a 2x scale, so we can only support
  /// running tests on a device that has a 2x scale.
  case unsupportedDevice
}
