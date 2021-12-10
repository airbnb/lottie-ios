// Created by Cal Stephens on 12/8/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import SnapshotTesting
import XCTest

@testable import Lottie

// MARK: - SnapshotTests

class SnapshotTests: XCTestCase {

  /// Snapshots all of the sample animation JSON files visible to this test target
  func testLottieSnapshots() throws {
    #if !os(iOS)
    // We only run snapshot tests on iOS, since running snapshot tests
    // for macOS and tvOS would triple the number of snapshot images
    // we have to check in to the repo.
    throw SnapshotError.unsupportedPlatform
    #endif

    for sampleAnimationURL in Bundle.module.urls(forResourcesWithExtension: "json", subdirectory: nil)! {
      let sampleAnimationName = sampleAnimationURL.lastPathComponent.replacingOccurrences(of: ".json", with: "")

      guard let animation = Animation.named(sampleAnimationName, bundle: .module) else {
        XCTFail("Could not parse \(sampleAnimationName).json")
        continue
      }

      for percent in [0, 0.25, 0.5, 0.75, 1.0] {
        let animationView = AnimationView(animation: animation)
        animationView.frame.size = animation.snapshotSize
        animationView.currentProgress = CGFloat(percent)

        assertSnapshot(
          matching: animationView,
          as: .image,
          named: "\(sampleAnimationName) (\(Int(percent * 100))%)")
      }
    }
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
}
