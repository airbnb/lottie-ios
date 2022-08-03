// Created by Cal Stephens on 1/10/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {

  // MARK: Internal

  /// Adds animations for the given `Rectangle` to this `CALayer`
  @nonobjc
  func addAnimations(
    for star: Star,
    context: LayerAnimationContext,
    pathMultiplier: PathMultiplier)
    throws
  {
    switch star.starType {
    case .star:
      try addStarAnimation(for: star, context: context, pathMultiplier: pathMultiplier)
    case .polygon:
      try addPolygonAnimation(for: star, context: context, pathMultiplier: pathMultiplier)
    case .none:
      break
    }
  }

  // MARK: Private

  @nonobjc
  private func addStarAnimation(
    for star: Star,
    context: LayerAnimationContext,
    pathMultiplier: PathMultiplier)
    throws
  {
    try addAnimation(
      for: .path,
      keyframes: try star.combinedKeyframes(context: context).keyframes,
      value: { keyframe in
        BezierPath.star(
          position: keyframe.position.pointValue,
          outerRadius: keyframe.outerRadius.cgFloatValue,
          innerRadius: keyframe.innerRadius.cgFloatValue,
          outerRoundedness: keyframe.outerRoundness.cgFloatValue,
          innerRoundedness: keyframe.innerRoundness.cgFloatValue,
          numberOfPoints: keyframe.points.cgFloatValue,
          rotation: keyframe.rotation.cgFloatValue,
          direction: star.direction)
          .cgPath()
          .duplicated(times: pathMultiplier)
      },
      context: context)
  }

  @nonobjc
  private func addPolygonAnimation(
    for star: Star,
    context: LayerAnimationContext,
    pathMultiplier: PathMultiplier)
    throws
  {
    try addAnimation(
      for: .path,
      keyframes: try star.combinedKeyframes(context: context).keyframes,
      value: { keyframe in
        BezierPath.polygon(
          position: keyframe.position.pointValue,
          numberOfPoints: keyframe.points.cgFloatValue,
          outerRadius: keyframe.outerRadius.cgFloatValue,
          outerRoundedness: keyframe.outerRoundness.cgFloatValue,
          rotation: keyframe.rotation.cgFloatValue,
          direction: star.direction)
          .cgPath()
          .duplicated(times: pathMultiplier)
      },
      context: context)
  }
}

extension Star {
  /// Data that represents how to render a star at a specific point in time
  struct Keyframe {
    let position: Vector3D
    let outerRadius: Vector1D
    let innerRadius: Vector1D
    let outerRoundness: Vector1D
    let innerRoundness: Vector1D
    let points: Vector1D
    let rotation: Vector1D
  }

  /// Creates a single array of animatable keyframes from the separate arrays of keyframes in this star/polygon
  func combinedKeyframes(context: LayerAnimationContext) throws -> KeyframeGroup<Keyframe> {
    let combinedKeyframes = Keyframes.combinedIfPossible(
      position,
      outerRadius,
      innerRadius ?? KeyframeGroup(Vector1D(0)),
      outerRoundness,
      innerRoundness ?? KeyframeGroup(Vector1D(0)),
      points,
      rotation,
      makeCombinedResult: Star.Keyframe.init)

    if let combinedKeyframes = combinedKeyframes {
      return combinedKeyframes
    } else {
      // If we weren't able to combine all of the keyframes, we have to take the timing values
      // from one property and use a fixed value for the other properties.
      return try position.map { positionValue in
        Keyframe(
          position: positionValue,
          outerRadius: try outerRadius.exactlyOneKeyframe(context: context, description: "star outerRadius"),
          innerRadius: try innerRadius?.exactlyOneKeyframe(context: context, description: "star innerRadius")
            ?? Vector1D(0),
          outerRoundness: try outerRoundness.exactlyOneKeyframe(context: context, description: "star outerRoundness"),
          innerRoundness: try innerRoundness?.exactlyOneKeyframe(context: context, description: "star innerRoundness")
            ?? Vector1D(0),
          points: try points.exactlyOneKeyframe(context: context, description: "star points"),
          rotation: try rotation.exactlyOneKeyframe(context: context, description: "star rotation"))
      }
    }
  }
}
