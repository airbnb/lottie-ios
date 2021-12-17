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

// MARK: - CALayer + KeyframeGroup

extension CALayer {
  /// Constructs a `CAKeyframeAnimation` that reflects the given `KeyframeGroup` data model,
  /// and adds it to this `CALayer`.
  func addAnimation<KeyframeValue, ValueRepresentation>(
    for keyPath: CAKeyPath<ValueRepresentation>,
    keyframes keyframeGroup: KeyframeGroup<KeyframeValue>?,
    value keyframeValueMapping: (KeyframeValue) -> ValueRepresentation,
    context: LayerAnimationContext)
  {
    guard let keyframeGroup = keyframeGroup else {
      return
    }

    precondition(!keyframeGroup.keyframes.isEmpty, "Keyframes for \"\(keyPath.name)\" must be non-empty")

    let animation = CAKeyframeAnimation(keyPath: keyPath.name)
    animation.duration = context.duration
    animation.repeatCount = context.timingConfiguration.repeatCount
    animation.autoreverses = context.timingConfiguration.autoreverses
    animation.timeOffset = context.timingConfiguration.timeOffset
    animation.isRemovedOnCompletion = false

    // Convert the list of `Keyframe<T>` into
    // the representation used by `CAKeyframeAnimation`
    var values = keyframeGroup.keyframes.map { keyframeModel in
      keyframeValueMapping(keyframeModel.value)
    }

    var keyTimes = keyframeGroup.keyframes.map { keyframeModel in
      NSNumber(value: Float(context.relativeTime(of: keyframeModel.time)))
    }

    // Compute the timing function between each keyframe and the subsequent keyframe
    var timingFunctions: [CAMediaTimingFunction] = []

    for (index, keyframe) in keyframeGroup.keyframes.enumerated()
      where index != keyframeGroup.keyframes.indices.last
    {
      let nextKeyframe = keyframeGroup.keyframes[index + 1]

      let controlPoint1 = keyframe.outTangent?.pointValue ?? .zero
      let controlPoint2 = nextKeyframe.inTangent?.pointValue ?? CGPoint(x: 1, y: 1)

      timingFunctions.append(CAMediaTimingFunction(
        controlPoints:
        Float(controlPoint1.x),
        Float(controlPoint1.y),
        Float(controlPoint2.x),
        Float(controlPoint2.y)))
    }

    // Validate that we have correct start (0.0) and end (1.0) keyframes.
    //
    // From the documentation of `CAKeyframeAnimation.keyTimes`:
    //
    //   If the `calculationMode` is set to `linear` or `cubic`, the first value in the array
    //   must be 0.0 and the last value must be 1.0. All intermediate values represent
    //   time points between the start and end times.
    //
    if keyTimes.first != 0.0 {
      keyTimes.insert(0.0, at: 0)
      values.insert(values.first!, at: 0)
      timingFunctions.insert(CAMediaTimingFunction(name: .linear), at: 0)
    }

    if keyTimes.last != 1.0 {
      keyTimes.append(1.0)
      values.append(values.last!)
      timingFunctions.append(CAMediaTimingFunction(name: .linear))
    }

    assert(
      values.count == keyTimes.count,
      "`values.count` must exactly equal `keyTimes.count`")

    assert(
      timingFunctions.count == (values.count - 1),
      "`timingFunctions.count` must exactly equal `values.count - 1`")

    animation.values = values
    animation.keyTimes = keyTimes
    animation.timingFunctions = timingFunctions

    add(animation, forKey: keyPath.name)
  }

}

// MARK: - LayerAnimationContext helpers

extension LayerAnimationContext {
  /// The relative time (between 0 and 1) of the given absolute time value.
  fileprivate func relativeTime(of absoluteTime: AnimationFrameTime) -> AnimationProgressTime {
    (absoluteTime / endFrame) + startFrame
  }
}
