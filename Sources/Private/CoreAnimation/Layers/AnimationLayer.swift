// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - AnimationLayer

/// A type of `CALayer` that can be used in a Lottie animation
///  - Layers backed by a `LayerModel` subclass should subclass `BaseCompositionLayer`
protocol AnimationLayer: CALayer {
  /// Instructs this layer to setup its `CAAnimation`s
  /// using the given `LayerAnimationContext`
  func setupAnimations(context: LayerAnimationContext) throws
}

// MARK: - LayerAnimationContext

// Context describing the timing parameters of the current animation
struct LayerAnimationContext {
  /// The animation being played
  let animation: Animation

  /// The timing configuration that should be applied to `CAAnimation`s
  let timingConfiguration: CoreAnimationLayer.CAMediaTimingConfiguration

  /// The absolute frame number that this animation begins at
  let startFrame: AnimationFrameTime

  /// The absolute frame number that this animation ends at
  let endFrame: AnimationFrameTime

  /// The set of custom Value Providers applied to this animation
  let valueProviderStore: ValueProviderStore

  /// Information about whether or not an animation is compatible with the Core Animation engine
  let compatibilityTracker: CompatibilityTracker

  /// The AnimationKeypath represented by the current layer
  var currentKeypath: AnimationKeypath

  /// A closure that remaps the given frame in the child layer's local time to a frame
  /// in the animation's overall global time
  private(set) var timeRemapping: ((AnimationFrameTime) -> AnimationFrameTime) = { $0 }

  /// Adds the given component string to the `AnimationKeypath` stored
  /// that describes the current path being configured by this context value
  func addingKeypathComponent(_ component: String) -> LayerAnimationContext {
    var context = self
    context.currentKeypath.keys.append(component)
    return context
  }

  /// The `AnimationProgressTime` for the given `AnimationFrameTime` within this layer,
  /// accounting for the `timeRemapping` applied to this layer
  func progressTime(for frame: AnimationFrameTime) -> AnimationProgressTime {
    animation.progressTime(forFrame: timeRemapping(frame), clamped: false)
  }

  /// Chains an additional `timeRemapping` closure onto this layer context
  func withTimeRemapping(
    _ additionalTimeRemapping: @escaping (AnimationFrameTime) -> AnimationFrameTime)
    -> LayerAnimationContext
  {
    var copy = self
    copy.timeRemapping = { [existingTimeRemapping = timeRemapping] time in
      existingTimeRemapping(additionalTimeRemapping(time))
    }
    return copy
  }
}
