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

  /// Dynamic value providers that should be applied to the animation
  var customValueProviders: [AnimationKeypath: AnyValueProvider] = [:]

  /// A custom `AnimationImageProvider` to use when rendering this animation
  var customImageProvider: AnimationImageProvider?
}

// MARK: Custom mapping

extension SnapshotConfiguration {
  /// Custom configurations for individual snapshot tests that
  /// cannot use the default configuration
  static let customMapping: [String: SnapshotConfiguration] = [
    /// These samples appear to render in a slightly non-deterministic way,
    /// depending on the test environment, so we have to decrease precision a bit.
    "Issues/issue_1407": .precision(0.9),
    "Nonanimating/FirstText": .precision(0.99),
    "Nonanimating/verifyLineHeight": .precision(0.99),

    /// Test cases for the `AnimationKeypath` / `AnyValueProvider` system
    "Switch": .customValueProviders([
      AnimationKeypath(keypath: "Switch Outline Outlines.Fill 1.Color"): ColorValueProvider(.black),
      AnimationKeypath(keypath: "Checkmark Outlines.Group 1.Stroke 1.Color"): ColorValueProvider(.black),
      AnimationKeypath(keypath: "Checkmark Outlines 2.Group 1.Stroke 1.Color"): ColorValueProvider(.black),
      AnimationKeypath(keypath: "X Outlines.Group 1.Stroke 1.Color"): ColorValueProvider(.black),
    ]),

    // Test cases for `AnimatedImageProvider`
    "Nonanimating/_dog": .customImageProvider(HardcodedImageProvider(imageName: "Samples/Images/dog.png")),
  ]
}

// MARK: Helpers

extension SnapshotConfiguration {
  /// The default configuration to use if no custom mapping is provided
  static let `default` = SnapshotConfiguration()

  /// The `SnapshotConfiguration` to use for the given sample JSON file name
  static func forSample(named sampleName: String) -> SnapshotConfiguration {
    if let customConfiguration = customMapping[sampleName] {
      return customConfiguration
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

  /// A `SnapshotConfiguration` value using the given custom value providers
  static func customValueProviders(
    _ customValueProviders: [AnimationKeypath: AnyValueProvider])
    -> SnapshotConfiguration
  {
    var configuration = SnapshotConfiguration.default
    configuration.customValueProviders = customValueProviders
    return configuration
  }

  /// A `SnapshotConfiguration` value using the given custom value providers
  static func customImageProvider(
    _ customImageProvider: AnimationImageProvider)
    -> SnapshotConfiguration
  {
    var configuration = SnapshotConfiguration.default
    configuration.customImageProvider = customImageProvider
    return configuration
  }
}

// MARK: - Color helpers

extension Color {
  static var black: Color {
    .init(r: 0, g: 0, b: 0, a: 1)
  }
}
