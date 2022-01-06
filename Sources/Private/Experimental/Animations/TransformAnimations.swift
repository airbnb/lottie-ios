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

  /// The opacity of the transform.
  var opacity: KeyframeGroup<Vector1D> { get }
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

// MARK: - TransformComponent

/// Individual animatable components within `Transform` values
enum TransformComponent: CaseIterable {
  case position
  case anchorPoint
  case scale
  case rotation
  case opacity
}

extension Set where Element == TransformComponent {
  static var all: Set<TransformComponent> {
    Set(TransformComponent.allCases)
  }
}

// MARK: - CALayer + TransformModel

extension CALayer {

  // MARK: Internal

  /// Adds animations for the listed `components` of the given `Transform` to this `CALayer`
  func addAnimations(
    for transformModel: TransformModel,
    components: Set<TransformComponent> = .all,
    context: LayerAnimationContext)
  {
    if components.contains(.position) {
      addPositionAnimations(from: transformModel, context: context)
    }

    if components.contains(.anchorPoint) {
      addAnchorPointAnimation(from: transformModel, context: context)
    }

    if components.contains(.scale) {
      addScaleAnimations(from: transformModel, context: context)
    }

    if components.contains(.rotation) {
      addRotationAnimation(from: transformModel, context: context)
    }

    if components.contains(.opacity) {
      addOpacityAnimation(from: transformModel, context: context)
    }
  }

  // MARK: Private

  private func addPositionAnimations(
    from transformModel: TransformModel,
    context: LayerAnimationContext)
  {
    if let positionKeyframes = transformModel._position?.keyframes {
      addAnimation(
        for: .position,
        keyframes: positionKeyframes,
        value: \.pointValue,
        context: context)
    } else if
      let xKeyframes = transformModel._positionX?.keyframes,
      let yKeyframes = transformModel._positionY?.keyframes
    {
      addAnimation(
        for: .positionX,
        keyframes: xKeyframes,
        value: \.cgFloatValue,
        context: context)

      addAnimation(
        for: .positionY,
        keyframes: yKeyframes,
        value: \.cgFloatValue,
        context: context)
    } else {
      fatalError("`Transform` values must provide either `position` or `positionX` / `positionY` keyframes")
    }
  }

  private func addAnchorPointAnimation(
    from transformModel: TransformModel,
    context: LayerAnimationContext)
  {
    addAnimation(
      for: .anchorPoint,
      keyframes: transformModel.anchorPoint.keyframes,
      value: { absoluteAnchorPoint in
        guard bounds.width > 0, bounds.height > 0 else {
          assertionFailure("Size must be non-zero before an animation can be played")
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

  private func addScaleAnimations(
    from transformModel: TransformModel,
    context: LayerAnimationContext)
  {
    addAnimation(
      for: .scaleX,
      keyframes: transformModel.scale.keyframes,
      value: { scale in
        // Lottie animation files express scale as a numerical percentage value
        // (e.g. 50%, 100%, 200%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.5, 1.0, 2.0).
        CGFloat(scale.x) / 100
      },
      context: context)

    addAnimation(
      for: .scaleY,
      keyframes: transformModel.scale.keyframes,
      value: { scale in
        // Lottie animation files express scale as a numerical percentage value
        // (e.g. 50%, 100%, 200%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.5, 1.0, 2.0).
        CGFloat(scale.y) / 100
      },
      context: context)
  }

  private func addRotationAnimation(
    from transformModel: TransformModel,
    context: LayerAnimationContext)
  {
    addAnimation(
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

  private func addOpacityAnimation(
    from transformModel: TransformModel,
    context: LayerAnimationContext)
  {
    addAnimation(
      for: .opacity,
      keyframes: transformModel.opacity.keyframes,
      value: {
        // Lottie animation files express opacity as a numerical percentage value
        // (e.g. 0%, 50%, 100%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.0, 0.5, 1.0).
        $0.cgFloatValue / 100
      },
      context: context)
  }

}
