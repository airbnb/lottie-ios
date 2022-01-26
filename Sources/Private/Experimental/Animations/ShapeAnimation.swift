// Created by Cal Stephens on 1/7/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds a `path` animation for the given `ShapeItem`
  func addAnimations(for shape: ShapeItem, context: LayerAnimationContext) {
    switch shape {
    case let customShape as Shape:
      addAnimations(for: customShape.path, context: context)

    case let ellipse as Ellipse:
      addAnimations(for: ellipse, context: context)

    case let rectangle as Rectangle:
      addAnimations(for: rectangle, context: context)

    case let star as Star:
      addAnimations(for: star, context: context)

    default:
      // None of the other `ShapeItem` subclasses draw a `path`
      return
    }
  }

  /// Adds a `fillColor` animation for the given `Fill` object
  func addAnimations(for fill: Fill, context: LayerAnimationContext) {
    fillRule = fill.fillRule.caFillRule

    addAnimation(
      for: .fillColor,
      keyframes: fill.color.keyframes,
      value: \.cgColorValue,
      context: context)
  }

  /// Adds animations for properties related to the given `Stroke` object (`strokeColor`, `lineWidth`, etc)
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
  func addAnimations(for trim: Trim, context: LayerAnimationContext) {
    addAnimation(
      for: .strokeStart,
      keyframes: trim.start.keyframes,
      value: { strokeStart in
        // Lottie animation files express stoke trims as a numerical percentage value
        // (e.g. 25%, 50%, 100%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.25, 0.5, 1.0).
        CGFloat(strokeStart.cgFloatValue) / 100
      }, context: context)

    addAnimation(
      for: .strokeEnd,
      keyframes: trim.end.keyframes,
      value: { strokeEnd in
        // Lottie animation files express stoke trims as a numerical percentage value
        // (e.g. 25%, 50%, 100%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.25, 0.5, 1.0).
        CGFloat(strokeEnd.cgFloatValue) / 100
      }, context: context)
  }
}
