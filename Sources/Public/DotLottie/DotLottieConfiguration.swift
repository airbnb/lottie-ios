//
// DotLottieConfiguration.swift
// Lottie
//
// Created by Evandro Hoffmann on 19/10/22.
//

// MARK: - DotLottieConfiguration

/// The `DotLottieConfiguration` model holds the presets extracted from DotLottieAnimation
/// The presets are used as input to setup `LottieAnimationView` before playing the animation.
public struct DotLottieConfiguration {
  /// id of the animation
  public var id: String

  /// Animation Image Provider
  public var imageProvider: AnimationImageProvider?

  /// Loop behaviour of animation
  public var loopMode: LottieLoopMode

  /// Playback speed of animation
  public var speed: Double
}
