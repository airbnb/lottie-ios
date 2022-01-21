// Created by Cal Stephens on 12/8/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import SnapshotTesting
import XCTest

#if canImport(UIKit)
import UIKit
#endif

@testable import LottieCore

// MARK: - SnapshotTests

class SnapshotTests: XCTestCase {

  // MARK: Internal

  /// Snapshots all of the sample animation JSON files visible to this test target
  func testLottieSnapshots() throws {
    try compareSampleSnapshots()
  }

  /// Snapshots sample animation files using the experimental rendering engine
  func testExperimentalRenderingEngine() throws {
    try compareSampleSnapshots(usingExperimentalRenderingEngine: true)
  }

  /// Validates that all of the snapshots in __Snapshots__ correspond to
  /// a sample JSON file that is visible to this test target.
  func testAllSnapshotsHaveCorrespondingSampleFile() {
    for snapshotURL in snapshotURLs {
      // The snapshot files follow the format `testCaseName.animationName-percentage.png`
      //  - We remove the known prefix and known suffixes to recover the input file name
      //  - `animationName` can contain dashes, so we can't just split the string at each dash
      var animationName = snapshotURL.lastPathComponent
        .replacingOccurrences(of: "testLottieSnapshots.", with: "")
        .replacingOccurrences(of: "testExperimentalRenderingEngine.", with: "")

      for percentage in progressPercentagesToSnapshot {
        animationName = animationName.replacingOccurrences(
          of: "-\(Int(percentage * 100)).png",
          with: "")
      }

      animationName = animationName.replacingOccurrences(of: "-", with: "/")

      XCTAssert(
        sampleAnimationURLs.contains(where: { $0.absoluteString.hasSuffix("\(animationName).json") }),
        "Snapshot \"\(snapshotURL.lastPathComponent)\" has no corresponding sample animation")
    }
  }

  /// Validates that all of the custom snapshot configurations in `SnapshotConfiguration.customMapping`
  /// reference a sample json file that actually exists
  func testCustomSnapshotConfigurationsHaveCorrespondingSampleFile() {
    for (animationName, _) in SnapshotConfiguration.customMapping {
      let expectedSampleFile = Bundle.module.bundleURL.appendingPathComponent("Samples/\(animationName).json")

      XCTAssert(
        sampleAnimationURLs.contains(expectedSampleFile),
        "Custom configuration for \"\(animationName)\" has no corresponding sample animation")
    }
  }

  /// Validates that this test target can access sample json files from `Tests/Samples`
  /// and snapshot images from `Tests/__Snapshots__`.
  func testCanAccessSamplesAndSnapshots() {
    XCTAssert(sampleAnimationURLs.count > 50)
    XCTAssert(snapshotURLs.count > 300)
  }

  override func setUp() {
    // We don't want assertions to crash the snapshot tests,
    // so we stub out the shared logger singleton
    LottieLogger.shared = LottieLogger(
      assert: { _, _, _, _ in },
      assertionFailure: { _, _, _ in },
      warn: { _, _, _ in })
  }

  override func tearDown() {
    LottieLogger.shared = LottieLogger()
  }

  // MARK: Private

  /// `currentProgress` percentages that should be snapshot in `compareSampleSnapshots`
  private let progressPercentagesToSnapshot = [0, 0.25, 0.5, 0.75, 1.0]

  /// The name of the directory that contains the sample json files
  private let samplesDirectoryName = "Samples"

  /// The list of snapshot image files in `Tests/__Snapshots__`
  private let snapshotURLs = Bundle.module.urls(forResourcesWithExtension: "png", subdirectory: nil)!

  /// The list of sample animation files in `Tests/Samples`
  private lazy var sampleAnimationURLs: [URL] = {
    let enumerator = FileManager.default.enumerator(atPath: Bundle.module.bundlePath)!

    var sampleAnimationURLs: [URL] = []

    while let fileSubpath = enumerator.nextObject() as? String {
      if
        fileSubpath.hasPrefix(samplesDirectoryName),
        fileSubpath.contains("json")
      {
        let fileURL = Bundle.module.bundleURL.appendingPathComponent(fileSubpath)
        sampleAnimationURLs.append(fileURL)
      }
    }

    return sampleAnimationURLs
  }()

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
      // Each of the sample animation URLs has the format
      // `.../*.bundle/Samples/{subfolder}/{animationName}.json`.
      // The sample animation name should include the subfolders
      // (since that helps uniquely identity the animation JSON file).
      let pathComponents = sampleAnimationURL.pathComponents
      let samplesIndex = pathComponents.lastIndex(of: samplesDirectoryName)!
      let subpath = pathComponents[(samplesIndex + 1)...]

      let sampleAnimationName = subpath
        .joined(separator: "/")
        .replacingOccurrences(of: ".json", with: "")

      let configuration = SnapshotConfiguration.forSample(named: sampleAnimationName)

      if usingExperimentalRenderingEngine, !configuration.testWithExperimentalRenderingEngine {
        continue
      }

      guard
        let animation = Animation.named(
          sampleAnimationName,
          bundle: .module,
          subdirectory: samplesDirectoryName)
      else {
        XCTFail("Could not parse Samples/\(sampleAnimationName).json")
        continue
      }

      for percent in progressPercentagesToSnapshot {
        let animationView = AnimationView(
          animation: animation,
          _experimentalFeatureConfiguration: ExperimentalFeatureConfiguration(
            useNewRenderingEngine: usingExperimentalRenderingEngine))

        // Set up the animation view with a valid frame
        // so the geometry is correct when setting up the `CAAnimation`s
        animationView.frame.size = animation.snapshotSize

        animationView.currentProgress = CGFloat(percent)

        for (keypath, customValueProvider) in configuration.customValueProviders {
          animationView.setValueProvider(customValueProvider, keypath: keypath)
        }

        if let customImageProvider = configuration.customImageProvider {
          animationView.imageProvider = customImageProvider
        }

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
