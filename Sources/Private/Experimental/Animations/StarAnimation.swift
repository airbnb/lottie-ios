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
  {
    switch star.starType {
    case .star:
      addStarAnimation(for: star, context: context)
    case .polygon:
      addPolygonAnimation(for: star, context: context)
    case .none:
      break
    }
  }

  // MARK: Private

  @nonobjc
  private func addStarAnimation(
    for star: Star,
    context: LayerAnimationContext)
  {
    addAnimation(
      for: .path,
      keyframes: star.position.keyframes,
      value: { position in
        // We can only use one set of keyframes to animate a given CALayer keypath,
        // so we currently animate `position` and ignore any other keyframes.
        // TODO: Is there a way to support this properly?
        BezierPath.star(
          position: position.pointValue,
          outerRadius: star.outerRadius.exactlyOneKeyframe.value.cgFloatValue,
          innerRadius: star.innerRadius?.exactlyOneKeyframe.value.cgFloatValue ?? 0,
          outerRoundedness: star.outerRoundness.exactlyOneKeyframe.value.cgFloatValue,
          innerRoundedness: star.innerRoundness?.exactlyOneKeyframe.value.cgFloatValue ?? 0,
          numberOfPoints: star.points.exactlyOneKeyframe.value.cgFloatValue,
          rotation: star.rotation.exactlyOneKeyframe.value.cgFloatValue,
          direction: star.direction)
          .cgPath()
      },
      context: context)
  }

  @nonobjc
  private func addPolygonAnimation(
    for star: Star,
    context: LayerAnimationContext)
  {
    addAnimation(
      for: .path,
      keyframes: star.position.keyframes,
      value: { position in
        // We can only use one set of keyframes to animate a given CALayer keypath,
        // so we currently animate `position` and ignore any other keyframes.
        // TODO: Is there a way to support this properly?
        BezierPath.polygon(
          position: position.pointValue,
          numberOfPoints: star.points.exactlyOneKeyframe.value.cgFloatValue,
          outerRadius: star.outerRadius.exactlyOneKeyframe.value.cgFloatValue,
          outerRoundedness: star.outerRoundness.exactlyOneKeyframe.value.cgFloatValue,
          rotation: star.rotation.exactlyOneKeyframe.value.cgFloatValue,
          direction: star.direction)
          .cgPath()
      },
      context: context)
  }
}
