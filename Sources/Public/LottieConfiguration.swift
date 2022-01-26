// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

// MARK: - LottieConfiguration

/// Global configuration options for Lottie animations
public struct LottieConfiguration: Hashable {

  public init(renderingEngine: RenderingEngine = .mainThread) {
    self.renderingEngine = renderingEngine
  }

  /// The global configuration of Lottie,
  /// which applies to all `AnimationView`s by default.
  public static var shared = LottieConfiguration()

  /// The rendering engine implementation to use when displaying an animation
  public var renderingEngine: RenderingEngine

}

// MARK: - RenderingEngine

/// The rendering engine implementation to use when displaying an animation
public enum RenderingEngine: Hashable {
  /// The original / default rendering engine, which supports all Lottie features
  /// but runs on the main thread, which comes with some CPU overhead.
  case mainThread

  /// The new rendering engine, that animates using Core Animation
  /// and has no CPU overhead but doesn't support all Lottie features.
  case coreAnimation
}
