// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - CAKeyPath

/// A strongly typed value that can be used as the `keyPath` of a `CAAnimation`
struct CAKeyPath<ValueRepresentation> {
  let name: String

  init(_ name: String) {
    self.name = name
  }
}

// MARK: keyPath definitions

/// Supported key paths and their expected value types are described
/// at https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/AnimatableProperties/AnimatableProperties.html#//apple_ref/doc/uid/TP40004514-CH11-SW1
/// and https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/Key-ValueCodingExtensions/Key-ValueCodingExtensions.html
extension CAKeyPath {
  static var position: CAKeyPath<CGPoint> { .init("transform.translation") }
  static var scale: CAKeyPath<CGFloat> { .init("transform.scale") }
  static var scaleX: CAKeyPath<CGFloat> { .init("transform.scale.x") }
  static var scaleY: CAKeyPath<CGFloat> { .init("transform.scale.y") }

  static var anchorPoint: CAKeyPath<CGPoint> { .init(#keyPath(CALayer.anchorPoint)) }
  static var opacity: CAKeyPath<CGFloat> { .init(#keyPath(CALayer.opacity)) }
}

// MARK: - KeyframeGroup + CAKeyframeAnimation

extension KeyframeGroup {
  /// Constructs a `CAKeyframeAnimation` that applies this `KeyframeGroup`
  /// to the given `keyPath` of a `CALayer`
  func caKeyframes<ValueRepresentation>(
    animating keyPath: CAKeyPath<ValueRepresentation>,
    value keyframeValueMapping: (T) -> ValueRepresentation,
    context: LayerAnimationContext)
    -> CAKeyframeAnimation
  {
    let animation = CAKeyframeAnimation(keyPath: keyPath.name)
    animation.duration = context.duration

    var values = [Any]()
    var keyTimes = [NSNumber]()

    for keyframeModel in keyframes {
      let keyframe = CAKeyframe(
        from: keyframeModel,
        using: keyframeValueMapping,
        context: context)

      values.append(keyframe.value)
      keyTimes.append(NSNumber(value: Float(keyframe.keyTime)))
    }

    animation.values = values
    animation.keyTimes = keyTimes
    return animation
  }

}

// MARK: - CAKeyframe

/// All of the information that describes a single keyframe in a `CAKeyframeAnimation`
fileprivate struct CAKeyframe<ValueRepresentation> {
  /// The value that will be applied to the keyPath of the layer being animated
  let value: ValueRepresentation

  /// The relative time (between 0 and 1) when this keyframe should be applied
  let keyTime: AnimationProgressTime

  // TODO: Support other properties like `timingFunctions`
}

extension CAKeyframe {
  /// Converts the given `Keyframe` data model into a `CAKeyframe` representation
  /// that can be used with a `CAKeyframeAnimation`.
  init<KeyframeModelValue>(
    from keyframeModel: Keyframe<KeyframeModelValue>,
    using mapping: (KeyframeModelValue) -> ValueRepresentation,
    context: LayerAnimationContext)
  {
    value = mapping(keyframeModel.value)
    keyTime = context.relativeTime(of: keyframeModel.time)
  }
}

// MARK: - LayerAnimationContext helpers

extension LayerAnimationContext {
  /// The relative time (between 0 and 1) of the given absolute time value.
  fileprivate func relativeTime(of absoluteTime: AnimationFrameTime) -> AnimationProgressTime {
    (absoluteTime / endFrame) + startFrame
  }
}
