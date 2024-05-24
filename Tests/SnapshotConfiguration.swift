// Created by Cal Stephens on 12/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

#if canImport(UIKit)
import Lottie
import UIKit

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

  /// A custom `AnimationKeypathTextProvider` to use when rendering this animation
  var customTextProvider: AnimationKeypathTextProvider?

  /// A custom `AnimationFontProvider` to use when rendering this animation
  var customFontProvider: AnimationFontProvider?

  /// Whether or not this sample should be tested with the automatic engine
  ///  - Defaults to `false` since this isn't necessary most of the time
  ///  - Enabling this for a set of animations gives us a regression suite for
  ///    the code supporting the automatic engine.
  var testWithAutomaticEngine = false

  /// Whether or not this sample should be excluded from testing with the Core Animation rendering engine
  ///  - Can be used for animations that are very expensive to render with the CA engine
  var excludeCoreAnimationRenderingEngine = false

  /// Custom progress values (from 0 to 1) that should be screenshot
  var customProgressValuesToSnapshot: [Double]?

  /// Custom frame values that should be screenshot
  var customFramesToSnapshot: [Double]?

  /// The maximum size to allow for the resulting snapshot image
  var maxSnapshotDimension: CGFloat = 500

  /// A `viewportFrame` value to apply to the `LottieAnimationView`, which crops the animation
  var customViewportFrame: CGRect?
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
    "Nonanimating/blend_mode_test": .precision(0.99),
    "Nonanimating/base64Test": .precision(0.9),
    "Issues/issue_2066": .precision(0.9),
    "LottieFiles/dog_car_ride": .precision(0.95),
    "Issues/issue_1800": .precision(0.95),
    "Issues/issue_1882": .precision(0.95),
    "Issues/issue_1717": .precision(0.95),
    "Issues/issue_1887": .precision(0.95),
    "Issues/issue_1683": .precision(0.93),
    "Issues/pr_1763": .precision(0.95),
    "Issues/pr_1964": .precision(0.95),
    "Issues/pr_1930_rx": .precision(0.93),
    "Issues/pr_1930_ry": .precision(0.93),
    "Issues/pr_1930_all_axis": .precision(0.93),
    "Issues/issue_1169_four_shadows": .precision(0.93),
    "DotLottie/animation_external_image": .precision(0.95),
    "DotLottie/animation_inline_image": .precision(0.95),
    "LottieFiles/gradient_shapes": .precision(0.95),

    /// Test cases for the `AnimationKeypath` / `AnyValueProvider` system
    "Nonanimating/keypathTest": .customValueProviders([
      "**.Stroke 1.Color": ColorValueProvider(.black),
      "**.Fill 1.Color": ColorValueProvider(.red),
    ]),

    "Switch": .customValueProviders([
      "Checkmark Outlines.Group 1.Stroke 1.Color": ColorValueProvider(.black),
      "Checkmark Outlines 2.Group 1.Stroke 1.Color": ColorValueProvider(.black),
      "X Outlines.Group 1.Stroke 1.Color": ColorValueProvider(.black),
      "Switch Outline Outlines.Fill 1.Color": ColorValueProvider([
        Keyframe(value: LottieColor.black, time: 0),
        Keyframe(value: LottieColor(r: 0.76, g: 0.76, b: 0.76, a: 1), time: 75),
        Keyframe(value: LottieColor.black, time: 150),
      ]),
    ]),

    "Issues/issue_1837_opacity": .customValueProviders([
      "Dark Gray Solid 1.Transform.Opacity": FloatValueProvider(10),
    ]),

    "Issues/issue_1837_scale_rotation": .customValueProviders([
      "H2.Transform.Scale": PointValueProvider(CGPoint(x: 200, y: 150)),
      "H2.Transform.Rotation": FloatValueProvider(90),
    ]),

    "Issues/issue_2042": .customValueProviders([
      "MASTER.Transform.Position": PointValueProvider(CGPoint(x: 214, y: 120)),
    ]),

    "Issues/issue_1664": .customValueProviders([
      "**.base_color.**.Color": ColorValueProvider(.black),
    ]).precision(0.95),

    "Issues/issue_1854": .customValueProviders([
      "**.Colors": GradientValueProvider(
        [
          LottieColor(r: 0, g: 0, b: 0, a: 0),
          LottieColor(r: 1, g: 1, b: 1, a: 0.5),
          LottieColor(r: 1, g: 1, b: 1, a: 1),
        ],
        locations: [0, 0.3, 1.0]),
    ]),

    "Issues/issue_1847": .customValueProviders([
      "**.Stroke 1.**.Color": ColorValueProvider(.red),
    ]),

    "Issues/issue_2150": .customValueProviders([
      "**.Color": ColorValueProvider(.red),
    ]),

    "Issues/issue_2094": .customValueProviders([
      "**.Stroke Width": FloatValueProvider(2),
    ]),

    "Issues/issue_2262": .customValueProviders([
      "**.Accent.**.Color": ColorValueProvider(.black),
    ]),

    // Test cases for `AnimatedImageProvider`
    //  - These snapshots are pretty large (2 MB) by default, so we limit their number and size.
    "Nonanimating/dog": .customImageProvider(HardcodedImageProvider(imageName: "Samples/Images/dog.png"))
      .nonanimating()
      .precision(0.9),
    "Nonanimating/dog_landscape": .customImageProvider(HardcodedImageProvider(imageName: "Samples/Images/dog-landscape.jpeg"))
      .nonanimating()
      .precision(0.9),

    // Test cases for `AnimationTextProvider`
    "Issues/issue_1722": .customTextProvider(HardcodedTextProvider(text: "Bounce-bounce")),

    "Issues/issue_1949_full_paths": SnapshotConfiguration
      .customTextProvider(DictionaryTextProvider([
        "ENVELOPE-FRONT.sender_username": "Lottie",
        "ENVELOPE-FRONT.From": "Airbnb (front)",
        "ENVELOPE-BACK-TEXTBOX.LETTER-TEXTBOX.sender_username": "Airbnb (back)",
        "ENVELOPE-BACK-TEXTBOX.LETTER-TEXTBOX.custom_text": "Text providers are cool!",
      ]))
      .progressValuesToSnapshot([0.3, 0.75]),

    "Issues/issue_1949_short_paths": SnapshotConfiguration
      .customTextProvider(DictionaryTextProvider([
        "sender_username": "Lottie",
        "From": "Airbnb",
        "custom_text": "Text providers are cool!",
      ]))
      .progressValuesToSnapshot([0.3, 0.75]),

    "Issues/issue_2209": SnapshotConfiguration.default
      .framesToSnapshot([
        4.999, // Should show frame 4
        5.0, // Should show frame 5
        9.9999999, // Should show frame 9
        10, // Should show frame 10
      ]),

    "Issues/issue_2226": SnapshotConfiguration.default
      .framesToSnapshot([
        19.25,
        113,
      ]),

    // Test cases for `AnimationFontProvider`
    "Nonanimating/Text_Glyph": .customFontProvider(HardcodedFontProvider(font: UIFont(name: "Chalkduster", size: 36)!)),

    // Test cases for `RenderingEngineOption.automatic`
    "9squares_AlBoardman": .useAutomaticRenderingEngine, // Supports the Core Animation engine
    "LottieFiles/shop": .useAutomaticRenderingEngine, // Throws a compatibility error in `init`
    "TypeFace/G": { // Throws a compatibility error in `display()`
      var configuration = SnapshotConfiguration.useAutomaticRenderingEngine
      configuration.customValueProviders = [
        "G 2.Ellipse 1.Stroke 1.Color": ColorValueProvider(.red),
        "G Outlines 3.G.Fill 1.Color": ColorValueProvider(.red),
        "Shape Layer 18.Shape 1.Stroke 2.Color": ColorValueProvider(.red),
      ]
      return configuration
    }(),

    /// Animations which are very expensive to render using the Core Animation rendering engine,
    /// and should fall back to the Main Thread engine when using `RenderingEngineOption.automatic`.
    "Issues/pr_2286": .excludeCoreAnimationRenderingEngine,

    // Other misc test cases
    "Issues/issue_2310": .customViewportFrame(
      CGRect(x: 0, y: 0, width: 85, height: 85).insetBy(dx: 10, dy: 10)),
  ]
}

// MARK: Helpers

extension SnapshotConfiguration {
  /// The default configuration to use if no custom mapping is provided
  static let `default` = SnapshotConfiguration()

  /// Opts this snapshot in to being tested with the automatic rendering engine option
  static var useAutomaticRenderingEngine: SnapshotConfiguration {
    var configuration = SnapshotConfiguration.default
    configuration.testWithAutomaticEngine = true
    return configuration
  }

  /// Excludes this snapshot from being tested with the Core Animation rendering engine.
  /// If this is the case then using the automatic engine should fall back to the main thread engine.
  static var excludeCoreAnimationRenderingEngine: SnapshotConfiguration {
    var configuration = SnapshotConfiguration.default
    configuration.excludeCoreAnimationRenderingEngine = true
    configuration.testWithAutomaticEngine = true
    return configuration
  }

  /// The `SnapshotConfiguration` to use for the given sample JSON file name
  static func forSample(named sampleName: String) -> SnapshotConfiguration {
    if let customConfiguration = customMapping[sampleName] {
      customConfiguration
    } else {
      .default
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

  static func customTextProvider(
    _ customTextProvider: AnimationKeypathTextProvider)
    -> SnapshotConfiguration
  {
    var configuration = SnapshotConfiguration.default
    configuration.customTextProvider = customTextProvider
    return configuration
  }

  /// A `SnapshotConfiguration` value using the given custom value providers
  static func customFontProvider(
    _ customFontProvider: AnimationFontProvider)
    -> SnapshotConfiguration
  {
    var configuration = SnapshotConfiguration.default
    configuration.customFontProvider = customFontProvider
    return configuration
  }

  /// A `SnapshotConfiguration` using the given custom `viewportFrame`
  static func customViewportFrame(_ viewportFrame: CGRect) -> SnapshotConfiguration {
    var configuration = SnapshotConfiguration.default
    configuration.customViewportFrame = viewportFrame
    return configuration
  }

  /// A copy of this `SnapshotConfiguration` with `customProgressValuesToSnapshot` updated to `[0]`
  func nonanimating(_ isNonanimating: Bool = true) -> SnapshotConfiguration {
    var copy = self
    copy.customProgressValuesToSnapshot = isNonanimating ? [0] : nil
    return copy
  }

  /// A copy of this `SnapshotConfiguration` with `customProgressValuesToSnapshot` set to the given value
  func progressValuesToSnapshot(_ progressValuesToSnapshot: [Double]) -> SnapshotConfiguration {
    var copy = self
    copy.customProgressValuesToSnapshot = progressValuesToSnapshot
    return copy
  }

  /// A copy of this `SnapshotConfiguration` with `customFramesToSnapshot` set to the given value
  func framesToSnapshot(_ framesToSnapshot: [Double]) -> SnapshotConfiguration {
    var copy = self
    copy.customFramesToSnapshot = framesToSnapshot
    return copy
  }

  /// A copy of this `SnapshotConfiguration` with `maxSnapshotDimension` set to the given value
  func maxSnapshotDimension(_ maxSnapshotDimension: CGFloat) -> SnapshotConfiguration {
    var copy = self
    copy.maxSnapshotDimension = maxSnapshotDimension
    return copy
  }

  /// A copy of this `SnapshotConfiguration` with the given precision when comparing the existing snapshot image
  func precision(_ precision: Float) -> SnapshotConfiguration {
    var copy = self
    copy.precision = precision
    return copy
  }

  /// Whether or not this sample should be included in the snapshot tests for the given configuration
  func shouldSnapshot(using configuration: LottieConfiguration) -> Bool {
    switch configuration.renderingEngine {
    case .automatic:
      testWithAutomaticEngine
    case .specific(.coreAnimation):
      !excludeCoreAnimationRenderingEngine
    case .specific(.mainThread):
      true
    }
  }
}

// MARK: - LottieColor helpers

extension LottieColor {
  static let black = LottieColor(r: 0, g: 0, b: 0, a: 1)
  static let red = LottieColor(r: 1, g: 0, b: 0, a: 1)
  static let blue = LottieColor(r: 0, g: 0, b: 1, a: 1)
}
#endif
