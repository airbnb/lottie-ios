// Created by Cal Stephens on 12/8/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import SnapshotTesting
import XCTest

#if canImport(UIKit)
import UIKit
#endif

@testable import Lottie

// MARK: - SnapshotTests

@MainActor
class SnapshotTests: XCTestCase {

  // MARK: Internal

  /// Snapshots all of the sample animation JSON files visible to this test target
  func testMainThreadRenderingEngine() async throws {
    try await compareSampleSnapshots(configuration: LottieConfiguration(renderingEngine: .mainThread))
  }

  /// Snapshots sample animation files using the Core Animation rendering engine
  func testCoreAnimationRenderingEngine() async throws {
    try await compareSampleSnapshots(configuration: LottieConfiguration(renderingEngine: .coreAnimation))
  }

  /// Snapshots sample animation files using the automatic rendering engine option
  func testAutomaticRenderingEngine() async throws {
    try await compareSampleSnapshots(configuration: LottieConfiguration(renderingEngine: .automatic))
  }

  /// Validates that all of the snapshots in __Snapshots__ correspond to
  /// a sample JSON file that is visible to this test target.
  func testAllSnapshotsHaveCorrespondingSampleFile() {
    for snapshotURL in Samples.snapshotURLs {
      // Exclude snapshots of private samples, since those aren't checked in to the repo
      if snapshotURL.lastPathComponent.contains("Private") {
        continue
      }

      // The snapshot files follow the format `testCaseName.animationName-percentage.png`
      //  - We remove the known prefix and known suffixes to recover the input file name
      //  - `animationName` can contain dashes, so we can't just split the string at each dash
      var animationName = snapshotURL.lastPathComponent
        .replacingOccurrences(of: "testMainThreadRenderingEngine.", with: "")
        .replacingOccurrences(of: "testCoreAnimationRenderingEngine.", with: "")
        .replacingOccurrences(of: "testAutomaticRenderingEngine.", with: "")

      for percentage in progressPercentagesToSnapshot {
        animationName = animationName.replacingOccurrences(
          of: "-\(Int(percentage * 100)).png",
          with: "")
      }

      animationName = animationName.replacingOccurrences(of: "-", with: "/")

      XCTAssert(
        Samples.sampleAnimationURLs.contains(where: { $0.absoluteString.hasSuffix("\(animationName).json") })
          || Samples.sampleAnimationURLs.contains(where: { $0.absoluteString.hasSuffix("\(animationName).lottie") }),
        "Snapshot \"\(snapshotURL.lastPathComponent)\" has no corresponding sample animation")
    }
  }

  /// Validates that all of the custom snapshot configurations in `SnapshotConfiguration.customMapping`
  /// reference a sample json file that actually exists
  func testCustomSnapshotConfigurationsHaveCorrespondingSampleFile() {
    for (animationName, _) in SnapshotConfiguration.customMapping {
      let expectedSampleFile = Bundle.module.bundleURL.appendingPathComponent("Samples/\(animationName).json")

      XCTAssert(
        Samples.sampleAnimationURLs.contains(expectedSampleFile),
        "Custom configuration for \"\(animationName)\" has no corresponding sample animation")
    }
  }

  /// Validates that this test target can access sample json files from `Tests/Samples`
  /// and snapshot images from `Tests/__Snapshots__`.
  func testCanAccessSamplesAndSnapshots() {
    XCTAssert(Samples.sampleAnimationURLs.count > 50)
    XCTAssert(Samples.snapshotURLs.count > 300)
  }

  override func setUp() {
    LottieLogger.shared = .printToConsole
    TestHelpers.snapshotTestsAreRunning = true
  }

  override func tearDown() {
    LottieLogger.shared = LottieLogger()
    TestHelpers.snapshotTestsAreRunning = false
  }

  // MARK: Private

  /// `currentProgress` percentages that should be snapshot in `compareSampleSnapshots`
  private let progressPercentagesToSnapshot = [0, 0.25, 0.5, 0.75, 1.0]

  /// Captures snapshots of `sampleAnimationURLs` and compares them to the snapshot images stored on disk
  private func compareSampleSnapshots(
    configuration: LottieConfiguration,
    testName: String = #function)
    async throws
  {
    #if os(iOS)
    guard UIScreen.main.scale == 2 else {
      /// Snapshots are captured at a 2x scale, so we can only support
      /// running tests on a device that has a 2x scale.
      ///  - In CI we run tests on an iPhone 8 simulator,
      ///    but any device with a 2x scale works.
      throw SnapshotError.unsupportedDevice
    }

    for sampleAnimationName in Samples.sampleAnimationNames {
      for percent in progressPercentagesToSnapshot {
        guard
          let animationView = await SnapshotConfiguration.makeAnimationView(
            for: sampleAnimationName,
            configuration: configuration)
        else { continue }

        animationView.currentProgress = CGFloat(percent)

        assertSnapshot(
          matching: animationView,
          as: .imageOfPresentationLayer(
            precision: SnapshotConfiguration.forSample(named: sampleAnimationName).precision),
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

extension LottieAnimation {
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

// MARK: - Samples

/// MARK: - Samples

enum Samples {
  /// The name of the directory that contains the sample json files
  static let directoryName = "Samples"

  /// The list of snapshot image files in `Tests/__Snapshots__`
  static let snapshotURLs = Bundle.module.fileURLs(
    in: "__Snapshots__",
    withSuffix: "png")

  /// The list of sample animation files in `Tests/Samples`
  static let sampleAnimationURLs = Bundle.module.fileURLs(in: Samples.directoryName, withSuffix: "json")
    + Bundle.module.fileURLs(in: Samples.directoryName, withSuffix: "lottie")

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
        bundle: .module,
        subdirectory: Samples.directoryName)
    else { return nil }

    return animation
  }

  static func dotLottie(named sampleDotLottieName: String) async -> DotLottieFile? {
    guard
      let dotLottieFile = try? await DotLottieFile.named(
        sampleDotLottieName,
        bundle: .module,
        subdirectory: Samples.directoryName)
    else {
      XCTFail("Could not parse Samples/\(sampleDotLottieName).lottie")
      return nil
    }

    return dotLottieFile
  }
}

extension SnapshotConfiguration {
  /// Creates a `LottieAnimationView` for the sample snapshot with the given name
  @MainActor
  static func makeAnimationView(
    for sampleAnimationName: String,
    configuration: LottieConfiguration,
    logger: LottieLogger = LottieLogger.shared)
    async -> LottieAnimationView?
  {
    let snapshotConfiguration = SnapshotConfiguration.forSample(named: sampleAnimationName)

    guard snapshotConfiguration.shouldSnapshot(using: configuration) else {
      return nil
    }

    let animationView: LottieAnimationView
    if let animation = Samples.animation(named: sampleAnimationName) {
      animationView = LottieAnimationView(
        animation: animation,
        configuration: configuration,
        logger: logger)
    } else if let dotLottieFile = await Samples.dotLottie(named: sampleAnimationName) {
      animationView = LottieAnimationView(
        dotLottie: dotLottieFile,
        configuration: configuration,
        logger: logger)
    } else {
      XCTFail("Couldn't create Animation View for \(sampleAnimationName)")
      return nil
    }

    guard let animation = animationView.animation else {
      XCTFail("Couldn't create Animation View for \(sampleAnimationName)")
      return nil
    }

    // Set up the animation view with a valid frame
    // so the geometry is correct when setting up the `CAAnimation`s
    animationView.frame.size = animation.snapshotSize

    for (keypath, customValueProvider) in snapshotConfiguration.customValueProviders {
      animationView.setValueProvider(customValueProvider, keypath: keypath)
    }

    if let customImageProvider = snapshotConfiguration.customImageProvider {
      animationView.imageProvider = customImageProvider
    }

    if let customTextProvider = snapshotConfiguration.customTextProvider {
      animationView.textProvider = customTextProvider
    }

    if let customFontProvider = snapshotConfiguration.customFontProvider {
      animationView.fontProvider = customFontProvider
    }

    return animationView
  }
}
