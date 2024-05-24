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
final class SnapshotTests: XCTestCase {

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

      for percentage in knownProgressPercentageValues {
        animationName = animationName.replacingOccurrences(
          of: "-\(Int(percentage * 100)).png",
          with: "")
      }

      for frame in knownFrameValues {
        animationName = animationName.replacingOccurrences(
          of: "-Frame-\(Int(frame)).png",
          with: "")
      }

      animationName = animationName.replacingOccurrences(of: "-", with: "/")

      XCTAssert(
        Samples.sampleAnimationURLs.contains(where: { $0.absoluteString.hasSuffix("\(animationName).json") })
          || Samples.sampleAnimationURLs.contains(where: { $0.absoluteString.hasSuffix("\(animationName).lottie") }),
        "Snapshot \"\(snapshotURL.lastPathComponent)\" has no corresponding sample animation. Expecting \(animationName).json|.lottie")
    }
  }

  /// Validates that all of the custom snapshot configurations in `SnapshotConfiguration.customMapping`
  /// reference a sample json file that actually exists
  func testCustomSnapshotConfigurationsHaveCorrespondingSampleFile() {
    for (animationName, _) in SnapshotConfiguration.customMapping {
      let expectedJsonFile = Bundle.lottie.bundleURL.appendingPathComponent("Samples/\(animationName).json")
      let expectedDotLottieFile = Bundle.lottie.bundleURL.appendingPathComponent("Samples/\(animationName).lottie")

      XCTAssert(
        Samples.sampleAnimationURLs.contains(expectedJsonFile)
          || Samples.sampleAnimationURLs.contains(expectedDotLottieFile),
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
    // Register fonts from the Samples/Fonts directory
    for fontAssetURL in Bundle.lottie.urls(forResourcesWithExtension: "ttf", subdirectory: "Samples/Fonts") ?? [] {
      CTFontManagerRegisterFontsForURL(fontAssetURL as CFURL, .process, nil)
    }

    LottieLogger.shared = .printToConsole
    TestHelpers.snapshotTestsAreRunning = true
    isRecording = false // Change it here to `true` if you want to generate the snapshots
  }

  override func tearDown() {
    LottieLogger.shared = LottieLogger()
    TestHelpers.snapshotTestsAreRunning = false
  }

  // MARK: Private

  /// The progress percentage values that are snapshot by default
  private static let defaultProgressPercentageValues: [Double] = [0, 0.25, 0.5, 0.75, 1.0]

  /// All of the `progressPercentagesToSnapshot` values used in the snapshot tests
  private let knownProgressPercentageValues: Set<Double> = Set(Samples.sampleAnimationNames.flatMap {
    SnapshotConfiguration.forSample(named: $0).customProgressValuesToSnapshot ?? defaultProgressPercentageValues
  })

  /// All of the `customFramesToSnapshot` values used in the snapshot tests
  private let knownFrameValues: Set<Double> = Set(Samples.sampleAnimationNames.flatMap {
    SnapshotConfiguration.forSample(named: $0).customFramesToSnapshot ?? []
  })

  /// Progress values or frames that should be snapshot in `compareSampleSnapshots`
  private func pausedStatesToSnapshot(for snapshotConfiguration: SnapshotConfiguration) -> [LottiePlaybackMode.PausedState] {
    if let customFramesToSnapshot = snapshotConfiguration.customFramesToSnapshot {
      return customFramesToSnapshot.map { .frame($0) }
    }

    if let customProgressValuesToSnapshot = snapshotConfiguration.customProgressValuesToSnapshot {
      for customProgressValue in customProgressValuesToSnapshot {
        assert(
          knownProgressPercentageValues.contains(customProgressValue),
          "All progress values being used must be listed in `knownProgressPercentageValues`")
      }

      return customProgressValuesToSnapshot.map { .progress($0) }
    }

    return SnapshotTests.defaultProgressPercentageValues.map { .progress($0) }
  }

  /// Captures snapshots of `sampleAnimationURLs` and compares them to the snapshot images stored on disk
  private func compareSampleSnapshots(
    configuration: LottieConfiguration,
    testName: String = #function)
    async throws
  {
    guard try SnapshotTests.enabled else { return }

    #if os(iOS)
    for sampleAnimationName in Samples.sampleAnimationNames {
      for pauseState in pausedStatesToSnapshot(for: SnapshotConfiguration.forSample(named: sampleAnimationName)) {
        guard SnapshotConfiguration.forSample(named: sampleAnimationName).shouldSnapshot(using: configuration) else {
          continue
        }

        guard
          let animationView = await SnapshotConfiguration.makeAnimationView(
            for: sampleAnimationName,
            configuration: configuration)
        else { continue }

        animationView.setPlaybackMode(.paused(at: pauseState))

        let pauseStateDescription: String =
          switch pauseState {
          case .progress(let percent):
            "\(Int(percent * 100))%"
          case .frame(let frame):
            "Frame \(Int(frame))"
          case .time(let time):
            "Time \(time))"
          case .marker(let markerName, position: _):
            markerName
          case .currentFrame:
            "Current Frame"
          }

        assertSnapshot(
          matching: animationView,
          as: .imageOfPresentationLayer(
            precision: SnapshotConfiguration.forSample(named: sampleAnimationName).precision,
            perceptualPrecision: 0.97),
          named: "\(sampleAnimationName) (\(pauseStateDescription))",
          testName: testName)
      }
    }
    #endif
  }

}

// MARK: Animation + snapshotSize

extension LottieAnimation {
  /// The size that this animation should be snapshot at
  func snapshotSize(for configuration: SnapshotConfiguration) -> CGSize {
    let maxDimension: CGFloat = configuration.maxSnapshotDimension

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

extension SnapshotTests {
  /// Whether or not snapshot tests should be enabled for the current build target
  static var enabled: Bool {
    get throws {
      #if os(iOS)
      if UIScreen.main.scale == 2 {
        return true
      } else {
        /// Snapshots are captured at a 2x scale, so we can only support
        /// running tests on a device that has a 2x scale.
        ///  - In CI we run tests on an iPhone 8 simulator,
        ///    but any device with a 2x scale works.
        throw SnapshotError.unsupportedDevice
      }
      #else
      // We only run snapshot tests on iOS, since running snapshot tests
      // for macOS and tvOS would triple the number of snapshot images
      // we have to check in to the repo.
      throw SnapshotError.unsupportedPlatform
      #endif
    }
  }
}

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

extension SnapshotConfiguration {
  /// Creates a `LottieAnimationView` for the sample snapshot with the given name
  @MainActor
  static func makeAnimationView(
    for sampleAnimationName: String,
    configuration: LottieConfiguration,
    logger: LottieLogger = LottieLogger.shared,
    customSnapshotConfiguration: SnapshotConfiguration? = nil)
    async -> LottieAnimationView?
  {
    let snapshotConfiguration = customSnapshotConfiguration ?? SnapshotConfiguration.forSample(named: sampleAnimationName)

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
    animationView.frame.size = animation.snapshotSize(for: snapshotConfiguration)

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

    if let customViewportFrame = snapshotConfiguration.customViewportFrame {
      animationView.viewportFrame = customViewportFrame
    }

    return animationView
  }
}
