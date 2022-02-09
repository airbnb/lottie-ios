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

  /// Adds animations for properties related to the given `Stroke` object (`strokeColor`, `lineWidth`, etc)
  @nonobjc
  func addAnimations(for stroke: Stroke, context: LayerAnimationContext) {
    lineJoin = stroke.lineJoin.caLineJoin
    lineCap = stroke.lineCap.caLineCap
    miterLimit = CGFloat(stroke.miterLimit)

    addAnimation(
      for: .strokeColor,
      keyframes: stroke.color.keyframes,
      value: \.cgColorValue,
      context: context)

    addAnimation(
      for: .lineWidth,
      keyframes: stroke.width.keyframes,
      value: \.cgFloatValue,
      context: context)

    if let (dashPattern, dashPhase) = stroke.dashPattern?.shapeLayerConfiguration {
      lineDashPattern = dashPattern.map {
        KeyframeGroup(keyframes: $0).exactlyOneKeyframe.value.cgFloatValue as NSNumber
      }

      addAnimation(
        for: .lineDashPhase,
        keyframes: dashPhase,
        value: \.cgFloatValue,
        context: context)
    }
  }

  /// Adds animations for `strokeStart` and `strokeEnd` from the given `Trim` object
  @nonobjc
  func addAnimations(for trim: Trim, context: LayerAnimationContext) {
    // `CAShapeLayer` requires that `strokeStart` be less than `strokeEnd`.
    //  - Since this isn't a requirement in the Lottie schema, there are
    //    some animations that have `strokeStart` and `strokeEnd` flipped.
    //  - If we detect that this is the case for this specific `Trim`, then
    //    we swap the start/end keyframes to match what `CAShapeLayer` expects.
    let strokeStartKeyframes: KeyframeGroup<Vector1D>
    let strokeEndKeyframes: KeyframeGroup<Vector1D>
    if trim.startValueIsAlwaysGreaterThanEndValue() {
      strokeStartKeyframes = trim.end
      strokeEndKeyframes = trim.start
    } else {
      strokeStartKeyframes = trim.start
      strokeEndKeyframes = trim.end
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
  /// Checks whether or not the value for `trim.start` is greater
  /// than the value for every `trim.end` at every keyframe.
  ///  - When this is the case, the start/end values need to be flipped
  ///    when applied to a `CAShapeLayer`, which requires that
  ///    `strokeStart` be less than `strokeEnd`.
  fileprivate func startValueIsAlwaysGreaterThanEndValue() -> Bool {
    let keyframeTimes = Set(start.keyframes.map { $0.time } + end.keyframes.map { $0.time })

    let startInterpolator = KeyframeInterpolator(keyframes: start.keyframes)
    let endInterpolator = KeyframeInterpolator(keyframes: end.keyframes)

    for keyframeTime in keyframeTimes {
      let startAtTime = startInterpolator.value(frame: keyframeTime) as! Vector1D
      let endAtTime = endInterpolator.value(frame: keyframeTime) as! Vector1D

      if startAtTime.cgFloatValue < endAtTime.cgFloatValue {
        return false
      }
    }

    return true
  }
}
