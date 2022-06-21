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
      keyframes: star.position.keyframes,
      value: { position in
        // We can only use one set of keyframes to animate a given CALayer keypath,
        // so we currently animate `position` and ignore any other keyframes.
        // TODO: Is there a way to support this properly?
        BezierPath.star(
          position: position.pointValue,
          outerRadius: try star.outerRadius
            .exactlyOneKeyframe(context: context, description: "outerRadius").value.cgFloatValue,
          innerRadius: try star.innerRadius?
            .exactlyOneKeyframe(context: context, description: "innerRadius").value.cgFloatValue ?? 0,
          outerRoundedness: try star.outerRoundness
            .exactlyOneKeyframe(context: context, description: "outerRoundness").value.cgFloatValue,
          innerRoundedness: try star.innerRoundness?
            .exactlyOneKeyframe(context: context, description: "innerRoundness").value.cgFloatValue ?? 0,
          numberOfPoints: try star.points
            .exactlyOneKeyframe(context: context, description: "points").value.cgFloatValue,
          rotation: try star.rotation
            .exactlyOneKeyframe(context: context, description: "rotation").value.cgFloatValue,
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
      keyframes: star.position.keyframes,
      value: { position in
        // We can only use one set of keyframes to animate a given CALayer keypath,
        // so we currently animate `position` and ignore any other keyframes.
        // TODO: Is there a way to support this properly?
        BezierPath.polygon(
          position: position.pointValue,
          numberOfPoints: try star.points
            .exactlyOneKeyframe(context: context, description: "numberOfPoints").value.cgFloatValue,
          outerRadius: try star.outerRadius
            .exactlyOneKeyframe(context: context, description: "outerRadius").value.cgFloatValue,
          outerRoundedness: try star.outerRoundness
            .exactlyOneKeyframe(context: context, description: "outerRoundedness").value.cgFloatValue,
          rotation: try star.rotation
            .exactlyOneKeyframe(context: context, description: "rotation").value.cgFloatValue,
          direction: star.direction)
          .cgPath()
          .duplicated(times: pathMultiplier)
      },
      context: context)
  }
}
