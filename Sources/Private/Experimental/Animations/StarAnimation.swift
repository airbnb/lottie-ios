// Created by Cal Stephens on 1/10/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {

  // MARK: Internal

  /// Adds animations for the given `Rectangle` to this `CALayer`
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
          outerRadius: star.outerRadius.keyframes[0].value.cgFloatValue,
          innerRadius: star.innerRadius?.keyframes[0].value.cgFloatValue ?? 0,
          outerRoundedness: star.outerRoundness.keyframes[0].value.cgFloatValue,
          innerRoundedness: star.innerRoundness?.keyframes[0].value.cgFloatValue ?? 0,
          numberOfPoints: star.points.keyframes[0].value.cgFloatValue,
          rotation: star.rotation.keyframes[0].value.cgFloatValue,
          direction: star.direction)
          .cgPath()
      },
      context: context)
  }

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
          numberOfPoints: star.points.keyframes[0].value.cgFloatValue,
          outerRadius: star.outerRadius.keyframes[0].value.cgFloatValue,
          outerRoundedness: star.outerRoundness.keyframes[0].value.cgFloatValue,
          rotation: star.rotation.keyframes[0].value.cgFloatValue,
          direction: star.direction)
          .cgPath()
      },
      context: context)
  }
}
