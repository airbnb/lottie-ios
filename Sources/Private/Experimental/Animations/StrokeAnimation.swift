// Created by Cal Stephens on 2/10/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Foundation
import QuartzCore

// MARK: - StrokeShapeItem

/// A `ShapeItem` that represents a stroke
protocol StrokeShapeItem {
  var opacity: KeyframeGroup<Vector1D> { get }
  var strokeColor: KeyframeGroup<Color>? { get }
  var width: KeyframeGroup<Vector1D> { get }
  var lineCap: LineCap { get }
  var lineJoin: LineJoin { get }
  var miterLimit: Double { get }
  var dashPattern: [DashElement]? { get }
}

// MARK: - Stroke + StrokeShapeItem

extension Stroke: StrokeShapeItem {
  var strokeColor: KeyframeGroup<Color>? { color }
}

// MARK: - GradientStroke + StrokeShapeItem

extension GradientStroke: StrokeShapeItem {
  var strokeColor: KeyframeGroup<Color>? { nil }
}

// MARK: - CAShapeLayer + StrokeShapeItem

extension CAShapeLayer {
  /// Adds animations for properties related to the given `Stroke` object (`strokeColor`, `lineWidth`, etc)
  @nonobjc
  func addStrokeAnimations(for stroke: StrokeShapeItem, context: LayerAnimationContext) {
    lineJoin = stroke.lineJoin.caLineJoin
    lineCap = stroke.lineCap.caLineCap
    miterLimit = CGFloat(stroke.miterLimit)

    if let strokeColor = stroke.strokeColor {
      addAnimation(
        for: .strokeColor,
        keyframes: strokeColor.keyframes,
        value: \.cgColorValue,
        context: context)
    }

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
}
