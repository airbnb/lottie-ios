// Created by Cal Stephens on 7/10/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import XCTest
import Lottie

// MARK: - Samples

/// MARK: - Samples

enum Samples {
  /// The name of the directory that contains the sample json files
  static let directoryName = "Samples"

  /// The list of snapshot image files in `Tests/__Snapshots__`
  static let snapshotURLs = Bundle.lottie.fileURLs(
    in: "__Snapshots__/SnapshotTests",
    withSuffix: "png")

  /// The list of sample animation files in `Tests/Samples`
  static let sampleAnimationURLs = Bundle.lottie.fileURLs(in: Samples.directoryName, withSuffix: "json")
    + Bundle.lottie.fileURLs(in: Samples.directoryName, withSuffix: "lottie")

  /// The list of sample animation names in `Tests/Samples`
  static let sampleAnimationNames = sampleAnimationURLs.lazy
    .map { sampleAnimationURL -> String in
      // Each of the sample animation URLs has the format
      // `.../*.bundle/Samples/{subfolder}/{animationName}.json`.
      // The sample animation name should include the subfolders
      // (since that helps uniquely identity the animation JSON file).
      let pathComponents = sampleAnimationURL.pathComponents
      let samplesIndex = pathComponents.lastIndex(of: Samples.directoryName)!
      let subpath = pathComponents[(samplesIndex + 1)...]

      return subpath
        .joined(separator: "/")
        .replacingOccurrences(of: ".json", with: "")
        .replacingOccurrences(of: ".lottie", with: "")
    }

  static func animation(named sampleAnimationName: String) -> LottieAnimation? {
    guard
      let animation = LottieAnimation.named(
        sampleAnimationName,
        bundle: .lottie,
        subdirectory: Samples.directoryName)
    else { return nil }

    return animation
  }

  static func dotLottie(named sampleDotLottieName: String) async -> DotLottieFile? {
    guard
      let dotLottieFile = try? await DotLottieFile.named(
        sampleDotLottieName,
        bundle: .lottie,
        subdirectory: Samples.directoryName)
    else {
      XCTFail("Could not parse Samples/\(sampleDotLottieName).lottie")
      return nil
    }

    return dotLottieFile
  }
}

