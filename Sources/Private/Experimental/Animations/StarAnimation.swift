// Created by Cal Stephens on 1/10/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {

  // MARK: Internal

  /// Adds animations for the given `Rectangle` to this `CALayer`
  @nonobjc
  func addAnimations(
    for star: Star,
    context: LayerAnimationContext)
    throws
  {
    switch star.starType {
    case .star:
      try addStarAnimation(for: star, context: context)
    case .polygon:
      try addPolygonAnimation(for: star, context: context)
    case .none:
      break
    }
  }

  // MARK: Private

  @nonobjc
  private func addStarAnimation(
    for star: Star,
    context: LayerAnimationContext)
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
          outerRadius: try context.exactlyOneKeyframe(from: star.outerRadius, description: "outerRadius").value.cgFloatValue,
          innerRadius: try context.exactlyOneKeyframe(from: star.innerRadius, description: "innerRadius")?.value
            .cgFloatValue ?? 0,
          outerRoundedness: try context.exactlyOneKeyframe(from: star.outerRoundness, description: "outerRoundness").value
            .cgFloatValue,
          innerRoundedness: try context.exactlyOneKeyframe(from: star.innerRoundness, description: "innerRoundness")?.value
            .cgFloatValue ?? 0,
          numberOfPoints: try context.exactlyOneKeyframe(from: star.points, description: "points").value.cgFloatValue,
          rotation: try context.exactlyOneKeyframe(from: star.rotation, description: "rotation").value.cgFloatValue,
          direction: star.direction)
          .cgPath()
      },
      context: context)
  }

  @nonobjc
  private func addPolygonAnimation(
    for star: Star,
    context: LayerAnimationContext)
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
          numberOfPoints: try context.exactlyOneKeyframe(from: star.points, description: "numberOfPoints").value.cgFloatValue,
          outerRadius: try context.exactlyOneKeyframe(from: star.outerRadius, description: "outerRadius").value.cgFloatValue,
          outerRoundedness: try context.exactlyOneKeyframe(from: star.outerRoundness, description: "outerRoundedness").value
            .cgFloatValue,
          rotation: try context.exactlyOneKeyframe(from: star.rotation, description: "rotation").value.cgFloatValue,
          direction: star.direction)
          .cgPath()
      },
      context: context)
  }
}
