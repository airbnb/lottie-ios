// Created by Cal Stephens on 12/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Lottie

// MARK: - SnapshotConfiguration

/// Snapshot configuration for an individual test case
struct SnapshotConfiguration {
  /// The precision that should be used when comparing the
  /// captured snapshot with the reference image in `Tests/__Snapshots`
  ///  - Defaults to 1.0 (the snapshot must match exactly).
  ///  - This can be lowered for snapshots that render somewhat nondeterministically,
  ///    but should be kept as high as possible (while still permitting the diff to succeed)
  var precision: Float = 1

  /// Whether or not this snapshot should be tested using the experimental rendering engine
  ///  - Defaults to false, since the experimental rendering engine
  ///    currently supports a relatively small number of animations.
  var testWithExperimentalRenderingEngine = false

  /// Dynamic value providers that should be applied to the animation
  var customValueProviders: [AnimationKeypath: AnyValueProvider] = [:]
}

// MARK: Custom mapping

extension SnapshotConfiguration {
  /// Custom configurations for individual snapshot tests that
  /// cannot use the default configuration
  static let customMapping: [String: SnapshotConfiguration] = [
    /// These samples appear to render in a slightly non-deterministic way,
    /// depending on the test environment, so we have to decrease precision a bit.
    "Issues/issue_1407": .init(precision: 0.9, testWithExperimentalRenderingEngine: true),
    "Nonanimating/FirstText": .precision(0.99),
    "Nonanimating/verifyLineHeight": .precision(0.99),

    /// These samples are known to be supported by the experimental rendering engine
    "9squares_AlBoardman": .testWithExperimentalRenderingEngine,
    "PinJump": .testWithExperimentalRenderingEngine,
    "IconTransitions": .testWithExperimentalRenderingEngine,
    "LottieLogo1": .testWithExperimentalRenderingEngine,
    "LottieLogo1_masked": .testWithExperimentalRenderingEngine,
    "MotionCorpse_Jrcanest": .testWithExperimentalRenderingEngine,
    "Switch_States": .testWithExperimentalRenderingEngine,
    "TwitterHeart": .testWithExperimentalRenderingEngine,
    "TwitterHeartButton": .testWithExperimentalRenderingEngine,
    "HamburgerArrow": .testWithExperimentalRenderingEngine,
    "vcTransition2": .testWithExperimentalRenderingEngine,
    "Watermelon": .testWithExperimentalRenderingEngine,
    "Nonanimating/Zoom": .testWithExperimentalRenderingEngine,
    "Nonanimating/GeometryTransformTest": .testWithExperimentalRenderingEngine,
    "Nonanimating/base64Test": .testWithExperimentalRenderingEngine,
    "LottieFiles/loading_dots_1": .testWithExperimentalRenderingEngine,
    "LottieFiles/loading_dots_2": .testWithExperimentalRenderingEngine,
    "LottieFiles/loading_dots_3": .testWithExperimentalRenderingEngine,
    "LottieFiles/gradient_1": .testWithExperimentalRenderingEngine,
    "LottieFiles/gradient_2": .testWithExperimentalRenderingEngine,
    "LottieFiles/gradient_pill": .testWithExperimentalRenderingEngine,
    "LottieFiles/gradient_square": .testWithExperimentalRenderingEngine,
    "TypeFace/B": .testWithExperimentalRenderingEngine,
    "TypeFace/Colon": .testWithExperimentalRenderingEngine,
    "TypeFace/Comma": .testWithExperimentalRenderingEngine,
    "TypeFace/C": .testWithExperimentalRenderingEngine,
    "TypeFace/D": .testWithExperimentalRenderingEngine,
    "TypeFace/E": .testWithExperimentalRenderingEngine,
    "TypeFace/F": .testWithExperimentalRenderingEngine,
    "TypeFace/I": .testWithExperimentalRenderingEngine,
    "TypeFace/J": .testWithExperimentalRenderingEngine,
    "TypeFace/K": .testWithExperimentalRenderingEngine,
    "TypeFace/L": .testWithExperimentalRenderingEngine,
    "TypeFace/N": .testWithExperimentalRenderingEngine,
    "TypeFace/R": .testWithExperimentalRenderingEngine,
    "TypeFace/T": .testWithExperimentalRenderingEngine,
    "TypeFace/W": .testWithExperimentalRenderingEngine,
    "TypeFace/X": .testWithExperimentalRenderingEngine,
    "TypeFace/Z": .testWithExperimentalRenderingEngine,

    // These samples are not quite perfect yet, but are looking pretty good:
    "vcTransition1": .testWithExperimentalRenderingEngine,
    "LottieLogo2": .testWithExperimentalRenderingEngine,
    "Issues/issue_1403": .testWithExperimentalRenderingEngine,
    "LottieFiles/gradient_shapes": .testWithExperimentalRenderingEngine,
    "TypeFace/H": .testWithExperimentalRenderingEngine,
    "TypeFace/O": .testWithExperimentalRenderingEngine,

    /// Test cases for the `AnimationKeypath` / `AnyValueProvider` system
    "Switch": .init(
      testWithExperimentalRenderingEngine: true,
      customValueProviders: [
        AnimationKeypath(keypath: "Switch Outline Outlines.Fill 1.Color"): ColorValueProvider(.black),
        AnimationKeypath(keypath: "Checkmark Outlines.Group 1.Stroke 1.Color"): ColorValueProvider(.black),
        AnimationKeypath(keypath: "Checkmark Outlines 2.Group 1.Stroke 1.Color"): ColorValueProvider(.black),
        AnimationKeypath(keypath: "X Outlines.Group 1.Stroke 1.Color"): ColorValueProvider(.black),
      ]),
  ]
}

// MARK: Helpers

extension SnapshotConfiguration {
  /// The default configuration to use if no custom mapping is provided
  static let `default` = SnapshotConfiguration()

  /// The default configuration to use for samples in `Samples/Private`
  static let defaultForPrivateSamples = SnapshotConfiguration.testWithExperimentalRenderingEngine

  /// A `SnapshotConfiguration` value with `testWithExperimentalRenderingEngine` customized to `true`
  static var testWithExperimentalRenderingEngine: SnapshotConfiguration {
    var configuration = SnapshotConfiguration.default
    configuration.testWithExperimentalRenderingEngine = true
    return configuration
  }

  /// The `SnapshotConfiguration` to use for the given sample JSON file name
  static func forSample(named sampleName: String) -> SnapshotConfiguration {
    if let customConfiguration = customMapping[sampleName] {
      return customConfiguration
    } else if sampleName.hasPrefix("Private/") {
      return .defaultForPrivateSamples
    } else {
      return .default
    }
  }

  /// A `SnapshotConfiguration` value with `precision` customized to the given value
  static func precision(_ precision: Float) -> SnapshotConfiguration {
    var configuration = SnapshotConfiguration.default
    configuration.precision = precision
    return configuration
  }
}

// MARK: - Color helpers

extension Color {
  static var black: Color {
    .init(r: 0, g: 0, b: 0, a: 1)
  }
}
