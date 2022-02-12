// Created by Cal Stephens on 1/7/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds a `path` animation for the given `ShapeItem`
  @nonobjc
  func addAnimations(for shape: ShapeItem, context: LayerAnimationContext) {
    switch shape {
    case let customShape as Shape:
      addAnimations(for: customShape.path, context: context)

    case let combinedShape as CombinedShapeItem:
      addAnimations(for: combinedShape, context: context)

    case let ellipse as Ellipse:
      addAnimations(for: ellipse, context: context)

    case let rectangle as Rectangle:
      addAnimations(for: rectangle, context: context)

    case let star as Star:
      addAnimations(for: star, context: context)

    default:
      // None of the other `ShapeItem` subclasses draw a `path`
      LottieLogger.shared.assertionFailure("Unexpected shape type \(type(of: shape))")
      return
    }
  }

  /// Adds a `fillColor` animation for the given `Fill` object
  @nonobjc
  func addAnimations(for fill: Fill, context: LayerAnimationContext) {
    fillRule = fill.fillRule.caFillRule

    addAnimation(
      for: .fillColor,
      keyframes: fill.color.keyframes,
      value: \.cgColorValue,
      context: context)
  }

  /// Adds animations for `strokeStart` and `strokeEnd` from the given `Trim` object
  @nonobjc
  func addAnimations(for trim: Trim, context: LayerAnimationContext) {
    let (strokeStartKeyframes, strokeEndKeyframes) = trim.caShapeLayerKeyframes()

    if trim.offset.keyframes.contains(where: { $0.value.cgFloatValue != 0 }) {
      LottieLogger.shared.assertionFailure("""
      The CoreAnimation rendering engine doesn't support Trim offsets
      """)
    }

    addAnimation(
      for: .strokeStart,
      keyframes: strokeStartKeyframes.keyframes,
      value: { strokeStart in
        // Lottie animation files express stoke trims as a numerical percentage value
        // (e.g. 25%, 50%, 100%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.25, 0.5, 1.0).
        CGFloat(strokeStart.cgFloatValue) / 100
      }, context: context)

    addAnimation(
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

  /// Checks whether or not the value for `trim.start` is greater
  /// than the value for every `trim.end` at every keyframe.
  fileprivate func startValueIsAlwaysGreaterThanEndValue() -> Bool {
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
