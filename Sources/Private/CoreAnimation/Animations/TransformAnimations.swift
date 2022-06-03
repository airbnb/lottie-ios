// Created by Cal Stephens on 12/17/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - TransformModel

/// This protocol mirrors the interface of `Transform`,
/// but it also implemented by `ShapeTransform` to allow
/// both transform types to share the same animation implementation.
protocol TransformModel {
  /// The anchor point of the transform.
  var anchorPoint: KeyframeGroup<Vector3D> { get }

  /// The position of the transform. This is nil if the position data was split.
  var _position: KeyframeGroup<Vector3D>? { get }

  /// The positionX of the transform. This is nil if the position property is set.
  var _positionX: KeyframeGroup<Vector1D>? { get }

  /// The positionY of the transform. This is nil if the position property is set.
  var _positionY: KeyframeGroup<Vector1D>? { get }

  /// The scale of the transform
  var scale: KeyframeGroup<Vector3D> { get }

  /// The rotation of the transform. Note: This is single dimensional rotation.
  var rotation: KeyframeGroup<Vector1D> { get }
}

// MARK: - Transform + TransformModel

extension Transform: TransformModel {
  var _position: KeyframeGroup<Vector3D>? { position }
  var _positionX: KeyframeGroup<Vector1D>? { positionX }
  var _positionY: KeyframeGroup<Vector1D>? { positionY }
}

// MARK: - ShapeTransform + TransformModel

extension ShapeTransform: TransformModel {
  var anchorPoint: KeyframeGroup<Vector3D> { anchor }
  var _position: KeyframeGroup<Vector3D>? { position }
  var _positionX: KeyframeGroup<Vector1D>? { nil }
  var _positionY: KeyframeGroup<Vector1D>? { nil }
}

// MARK: - CALayer + TransformModel

extension CALayer {

  // MARK: Internal

  /// Adds transform-related animations from the given `TransformModel` to this layer
  ///  - This _doesn't_ apply `transform.opacity`, which has to be handled separately
  ///    since child layers don't inherit the `opacity` of their parent.
  @nonobjc
  func addTransformAnimations(for transformModel: TransformModel, context: LayerAnimationContext) throws {
    try addPositionAnimations(from: transformModel, context: context)
    try addAnchorPointAnimation(from: transformModel, context: context)
    try addScaleAnimations(from: transformModel, context: context)
    try addRotationAnimation(from: transformModel, context: context)
  }

  // MARK: Private

  @nonobjc
  private func addPositionAnimations(
    from transformModel: TransformModel,
    context: LayerAnimationContext)
    throws
  {
    if let positionKeyframes = transformModel._position?.keyframes {
      try addAnimation(
        for: .position,
        keyframes: positionKeyframes,
        value: \.pointValue,
        context: context)
    } else if
      let xKeyframes = transformModel._positionX?.keyframes,
      let yKeyframes = transformModel._positionY?.keyframes
    {
      try addAnimation(
        for: .positionX,
        keyframes: xKeyframes,
        value: \.cgFloatValue,
        context: context)

      try addAnimation(
        for: .positionY,
        keyframes: yKeyframes,
        value: \.cgFloatValue,
        context: context)
    } else {
      try context.logCompatibilityIssue("""
        `Transform` values must provide either `position` or `positionX` / `positionY` keyframes
        """)
    }
  }

  @nonobjc
  private func addAnchorPointAnimation(
    from transformModel: TransformModel,
    context: LayerAnimationContext)
    throws
  {
    try addAnimation(
      for: .anchorPoint,
      keyframes: transformModel.anchorPoint.keyframes,
      value: { absoluteAnchorPoint in
        guard bounds.width > 0, bounds.height > 0 else {
          context.logger.assertionFailure("Size must be non-zero before an animation can be played")
          return .zero
        }

        // Lottie animation files express anchorPoint as an absolute point value,
        // so we have to divide by the width/height of this layer to get the
        // relative decimal values expected by Core Animation.
        return CGPoint(
          x: CGFloat(absoluteAnchorPoint.x) / bounds.width,
          y: CGFloat(absoluteAnchorPoint.y) / bounds.height)
      },
      context: context)
  }

  @nonobjc
  private func addScaleAnimations(
    from transformModel: TransformModel,
    context: LayerAnimationContext)
    throws
  {
    try addAnimation(
      for: .scaleX,
      keyframes: transformModel.scale.keyframes,
      value: { scale in
        // Lottie animation files express scale as a numerical percentage value
        // (e.g. 50%, 100%, 200%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.5, 1.0, 2.0).
        //  - Negative `scale.x` values aren't applied correctly by Core Animation.
        //    This appears to be because we animate `transform.scale.x` and `transform.scale.y`
        //    as separate `CAKeyframeAnimation`s instead of using a single animation of `transform` itself.
        //    https://openradar.appspot.com/FB9862872
        //  - To work around this, we set up a `rotationY` animation below
        //    to flip the view horizontally, which gives us the desired effect.
        abs(CGFloat(scale.x) / 100)
      },
      context: context)

    // When `scale.x` is negative, we have to rotate the view
    // half way around the y axis to flip it horizontally.
    //  - We don't do this in snapshot tests because it breaks the tests
    //    in surprising ways that don't happen at runtime. Definitely not ideal.
    if TestHelpers.snapshotTestsAreRunning {
      if transformModel.scale.keyframes.contains(where: { $0.value.x < 0 }) {
        context.logger.warn("""
          Negative `scale.x` values are not displayed correctly in snapshot tests
          """)
      }
    } else {
      try addAnimation(
        for: .rotationY,
        keyframes: transformModel.scale.keyframes,
        value: { scale in
          if scale.x < 0 {
            return .pi
          } else {
            return 0
          }
        },
        context: context)
    }

    try addAnimation(
      for: .scaleY,
      keyframes: transformModel.scale.keyframes,
      value: { scale in
        // Lottie animation files express scale as a numerical percentage value
        // (e.g. 50%, 100%, 200%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.5, 1.0, 2.0).
        //  - Negative `scaleY` values are correctly applied (they flip the view
        //    vertically), so we don't have to apply an additional rotation animation
        //    like we do for `scaleX`.
        CGFloat(scale.y) / 100
      },
      context: context)
  }

  private func addRotationAnimation(
    from transformModel: TransformModel,
    context: LayerAnimationContext)
    throws
  {
    try addAnimation(
      for: .rotation,
      keyframes: transformModel.rotation.keyframes,
      value: { rotationDegrees in
        // Lottie animation files express rotation in degrees
        // (e.g. 90º, 180º, 360º) so we covert to radians to get the
        // values expected by Core Animation (e.g. π/2, π, 2π)
        rotationDegrees.cgFloatValue * .pi / 180
      },
      context: context)
  }

}
