// Created by Cal Stephens on 2/10/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Foundation
import QuartzCore

// MARK: - StrokeShapeItem

/// A `ShapeItem` that represents a stroke
protocol StrokeShapeItem: OpacityAnimationModel {
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
  func addStrokeAnimations(for stroke: StrokeShapeItem, context: LayerAnimationContext) throws {
    lineJoin = stroke.lineJoin.caLineJoin
    lineCap = stroke.lineCap.caLineCap
    miterLimit = CGFloat(stroke.miterLimit)

    if let strokeColor = stroke.strokeColor {
      try addAnimation(
        for: .strokeColor,
        keyframes: strokeColor.keyframes,
        value: \.cgColorValue,
        context: context)
    }

    try addAnimation(
      for: .lineWidth,
      keyframes: stroke.width.keyframes,
      value: \.cgFloatValue,
      context: context)

    try addOpacityAnimation(for: stroke, context: context)

    if let (dashPattern, dashPhase) = stroke.dashPattern?.shapeLayerConfiguration {
      lineDashPattern = try dashPattern.map {
        try KeyframeGroup(keyframes: $0)
          .exactlyOneKeyframe(context: context, description: "stroke dashPattern").cgFloatValue as NSNumber
      }

      // If all of the items in the dash pattern are zeros, then we shouldn't attempt to render it.
      // This causes Core Animation to have extremely poor performance for some reason, even though
      // it doesn't affect the appearance of the animation.
      //  - We check for `== 0.01` instead of `== 0` because `dashPattern.shapeLayerConfiguration`
      //    converts all `0` values to `0.01` to work around a different Core Animation rendering issue.
      if lineDashPattern?.allSatisfy({ $0.floatValue == 0.01 }) == true {
        lineDashPattern = nil
      }

      try addAnimation(
        for: .lineDashPhase,
        keyframes: dashPhase,
        value: \.cgFloatValue,
        context: context)
    }
  }
}
