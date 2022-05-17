// Created by Cal Stephens on 1/7/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds a `path` animation for the given `ShapeItem`
  @nonobjc
  func addAnimations(for shape: ShapeItem, context: LayerAnimationContext) throws {
    switch shape {
    case let customShape as Shape:
      try addAnimations(for: customShape.path, context: context)

    case let combinedShape as CombinedShapeItem:
      try addAnimations(for: combinedShape, context: context)

    case let ellipse as Ellipse:
      try addAnimations(for: ellipse, context: context)

    case let rectangle as Rectangle:
      try addAnimations(for: rectangle, context: context)

    case let star as Star:
      try addAnimations(for: star, context: context)

    default:
      // None of the other `ShapeItem` subclasses draw a `path`
      try context.logCompatibilityIssue("Unexpected shape type \(type(of: shape))")
      return
    }
  }

  /// Adds a `fillColor` animation for the given `Fill` object
  @nonobjc
  func addAnimations(for fill: Fill, context: LayerAnimationContext) throws {
    fillRule = fill.fillRule.caFillRule

    try addAnimation(
      for: .fillColor,
      keyframes: fill.color.keyframes,
      value: \.cgColorValue,
      context: context)

    try addOpacityAnimation(for: fill, context: context)
  }

  /// Adds animations for `strokeStart` and `strokeEnd` from the given `Trim` object
  @nonobjc
  func addAnimations(for trim: Trim, context: LayerAnimationContext) throws {
    let (strokeStartKeyframes, strokeEndKeyframes) = trim.caShapeLayerKeyframes()

    if trim.offset.keyframes.contains(where: { $0.value.cgFloatValue != 0 }) {
      try context.logCompatibilityIssue("""
        The CoreAnimation rendering engine doesn't support Trim offsets
        """)
    }

    try addAnimation(
      for: .strokeStart,
      keyframes: strokeStartKeyframes.keyframes,
      value: { strokeStart in
        // Lottie animation files express stoke trims as a numerical percentage value
        // (e.g. 25%, 50%, 100%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.25, 0.5, 1.0).
        CGFloat(strokeStart.cgFloatValue) / 100
      }, context: context)

    try addAnimation(
      for: .strokeEnd,
      keyframes: strokeEndKeyframes.keyframes,
      value: { strokeEnd in
        // Lottie animation files express stoke trims as a numerical percentage value
        // (e.g. 25%, 50%, 100%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.25, 0.5, 1.0).
        CGFloat(strokeEnd.cgFloatValue) / 100
      }, context: context)
  }
}

extension Trim {

  // MARK: Fileprivate

  /// The `strokeStart` and `strokeEnd` keyframes to apply to a `CAShapeLayer`
  ///  - `CAShapeLayer` requires that `strokeStart` be less than `strokeEnd`.
  ///  - Since this isn't a requirement in the Lottie schema, there are
  ///    some animations that have `strokeStart` and `strokeEnd` flipped.
  ///  - If we detect that this is the case for this specific `Trim`, then
  ///    we swap the start/end keyframes to match what `CAShapeLayer` expects.
  fileprivate func caShapeLayerKeyframes()
    -> (strokeStart: KeyframeGroup<Vector1D>, strokeEnd: KeyframeGroup<Vector1D>)
  {
    if startValueIsAlwaysGreaterThanEndValue() {
      return (strokeStart: end, strokeEnd: start)
    } else {
      return (strokeStart: start, strokeEnd: end)
    }
  }

  // MARK: Private

  /// Checks whether or not the value for `trim.start` is greater
  /// than the value for every `trim.end` at every keyframe.
  private func startValueIsAlwaysGreaterThanEndValue() -> Bool {
    let keyframeTimes = Set(start.keyframes.map { $0.time } + end.keyframes.map { $0.time })

    let startInterpolator = KeyframeInterpolator(keyframes: start.keyframes)
    let endInterpolator = KeyframeInterpolator(keyframes: end.keyframes)

    for keyframeTime in keyframeTimes {
      guard
        let startAtTime = startInterpolator.value(frame: keyframeTime) as? Vector1D,
        let endAtTime = endInterpolator.value(frame: keyframeTime) as? Vector1D
      else { continue }

      if startAtTime.cgFloatValue < endAtTime.cgFloatValue {
        return false
      }
    }

    return true
  }
}
