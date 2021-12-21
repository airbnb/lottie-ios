// Created by Cal Stephens on 12/17/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

protocol TransformModel {
  /// The anchor point of the transform.
  var anchorPoint: KeyframeGroup<Vector3D> { get }

  /// The position of the transform.
  var _position: KeyframeGroup<Vector3D> { get }

  /// The scale of the transform
  var scale: KeyframeGroup<Vector3D> { get }

  /// The rotation of the transform. Note: This is single dimensional rotation.
  var rotation: KeyframeGroup<Vector1D> { get }

  /// The opacity of the transform.
  var opacity: KeyframeGroup<Vector1D> { get }
}

extension Transform: TransformModel {
  var _position: KeyframeGroup<Vector3D> {
    guard let position = position else {
      // TODO:
      fatalError("Need to handle separate positionX and positionY keyframes")
      // maybe by always using `positionX` and `positionY` and
      // just mapping `position` to those two?
    }
    return position
  }
}

extension ShapeTransform: TransformModel {
  var _position: KeyframeGroup<Vector3D> { position }
  var anchorPoint: KeyframeGroup<Vector3D> { anchor }
}

extension CALayer {
  /// Adds animations for the given `Transform` to this `CALayer`
  func addAnimations(
    for transformModel: TransformModel,
    context: LayerAnimationContext,
    applyOpacity: Bool = true)
  {
    addAnimation(
      for: .position,
      keyframes: transformModel._position.keyframes,
      value: \.pointValue,
      context: context)

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

    if applyOpacity {
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
}
