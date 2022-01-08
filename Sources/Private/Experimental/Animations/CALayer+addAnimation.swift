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
  static var positionX: CAKeyPath<CGFloat> { .init("transform.translation.y") }
  static var positionY: CAKeyPath<CGFloat> { .init("transform.translation.x") }
  static var scale: CAKeyPath<CGFloat> { .init("transform.scale") }
  static var scaleX: CAKeyPath<CGFloat> { .init("transform.scale.x") }
  static var scaleY: CAKeyPath<CGFloat> { .init("transform.scale.y") }
  static var rotation: CAKeyPath<CGFloat> { .init("transform.rotation") }

  static var anchorPoint: CAKeyPath<CGPoint> { .init(#keyPath(CALayer.anchorPoint)) }
  static var opacity: CAKeyPath<CGFloat> { .init(#keyPath(CALayer.opacity)) }

  static var path: CAKeyPath<CGPath> { .init(#keyPath(CAShapeLayer.path)) }
  static var fillColor: CAKeyPath<CGColor> { .init(#keyPath(CAShapeLayer.fillColor)) }
  static var lineWidth: CAKeyPath<CGFloat> { .init(#keyPath(CAShapeLayer.lineWidth)) }
  static var strokeColor: CAKeyPath<CGColor> { .init(#keyPath(CAShapeLayer.strokeColor)) }
  static var strokeStart: CAKeyPath<CGFloat> { .init(#keyPath(CAShapeLayer.strokeStart)) }
  static var strokeEnd: CAKeyPath<CGFloat> { .init(#keyPath(CAShapeLayer.strokeEnd)) }

  static var colors: CAKeyPath<[CGColor]> { .init(#keyPath(CAGradientLayer.colors)) }
  static var locations: CAKeyPath<[CGFloat]> { .init(#keyPath(CAGradientLayer.locations)) }
  static var startPoint: CAKeyPath<CGPoint> { .init(#keyPath(CAGradientLayer.startPoint)) }
  static var endPoint: CAKeyPath<CGPoint> { .init(#keyPath(CAGradientLayer.endPoint)) }
}

// MARK: - CALayer + addAnimation

extension CALayer {
  /// Constructs a `CAKeyframeAnimation` that reflects the given keyframes,
  /// and adds it to this `CALayer`.
  func addAnimation<KeyframeValue, ValueRepresentation>(
    for keyPath: CAKeyPath<ValueRepresentation>,
    keyframes: ContiguousArray<Keyframe<KeyframeValue>>,
    value keyframeValueMapping: (KeyframeValue) -> ValueRepresentation,
    context: LayerAnimationContext)
  {
    precondition(!keyframes.isEmpty, "Keyframes for \"\(keyPath.name)\" must be non-empty")

    let animation = CAKeyframeAnimation(keyPath: keyPath.name)

    // Convert the list of `Keyframe<T>` into
    // the representation used by `CAKeyframeAnimation`
    var values = keyframes.map { keyframeModel in
      keyframeValueMapping(keyframeModel.value)
    }

    var keyTimes = keyframes.map { keyframeModel -> NSNumber in
      let progressTime = context.animation.progressTime(forFrame: keyframeModel.time, clamped: false)
      return NSNumber(value: Float(progressTime))
    }

    // Compute the timing function between each keyframe and the subsequent keyframe
    var timingFunctions: [CAMediaTimingFunction] = []

    for (index, keyframe) in keyframes.enumerated()
      where index != keyframes.indices.last
    {
      let nextKeyframe = keyframes[index + 1]

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

    add(animation.timed(with: context), forKey: keyPath.name)
  }

}
