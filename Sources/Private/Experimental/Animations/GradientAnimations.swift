// Created by Cal Stephens on 1/7/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - GradientShapeItem

/// A `ShapeItem` that represents a gradient
protocol GradientShapeItem {
  var opacity: KeyframeGroup<Vector1D> { get }
  var startPoint: KeyframeGroup<Vector3D> { get }
  var endPoint: KeyframeGroup<Vector3D> { get }
  var gradientType: GradientType { get }
  var numberOfColors: Int { get }
  var colors: KeyframeGroup<[Double]> { get }
}

// MARK: - GradientFill + GradientShapeItem

extension GradientFill: GradientShapeItem { }

// MARK: - GradientStroke + GradientShapeItem

extension GradientStroke: GradientShapeItem { }

// MARK: - GradientRenderLayer + GradientShapeItem

extension GradientRenderLayer {

  // MARK: Internal

  /// Adds gradient-related animations to this layer, from the given `GradientFill`
  func addGradientAnimations(for gradient: GradientShapeItem, context: LayerAnimationContext) {
    // We have to set `colors` to a non-nil value with some valid number of colors
    // for the color animation below to have any effect
    colors = .init(
      repeating: CGColor.rgb(0, 0, 0),
      count: gradient.numberOfColors)

    addAnimation(
      for: .colors,
      keyframes: gradient.colors.keyframes,
      value: { colorComponents in
        gradient.colorConfiguration(from: colorComponents).map { $0.color }
      },
      context: context)

    addAnimation(
      for: .locations,
      keyframes: gradient.colors.keyframes,
      value: { colorComponents in
        gradient.colorConfiguration(from: colorComponents).map { $0.location }
      },
      context: context)

    switch gradient.gradientType {
    case .linear:
      addLinearGradientAnimations(for: gradient, context: context)
    case .radial:
      addRadialGradientAnimations(for: gradient)
    case .none:
      break
    }
  }

  // MARK: Private

  private func addLinearGradientAnimations(
    for gradient: GradientShapeItem,
    context: LayerAnimationContext)
  {
    type = .axial

    addAnimation(
      for: .startPoint,
      keyframes: gradient.startPoint.keyframes,
      value: { absoluteStartPoint in
        percentBasedPointInBounds(from: absoluteStartPoint.pointValue)
      },
      context: context)

    addAnimation(
      for: .endPoint,
      keyframes: gradient.endPoint.keyframes,
      value: { absoluteEndPoint in
        percentBasedPointInBounds(from: absoluteEndPoint.pointValue)
      },
      context: context)
  }

  private func addRadialGradientAnimations(for gradient: GradientShapeItem) {
    type = .radial

    // To draw the correct gradients, we have to derive a custom `endPoint`
    // relative to the `startPoint` value. Since calculating the `endPoint`
    // at any given time requires knowing the current `startPoint`,
    // we can't allow them to animate separately.
    let absoluteStartPoint = gradient.startPoint.exactlyOneKeyframe.value.pointValue
    let absoluteEndPoint = gradient.endPoint.exactlyOneKeyframe.value.pointValue

    startPoint = percentBasedPointInBounds(from: absoluteStartPoint)

    let radius = absoluteStartPoint.distanceTo(absoluteEndPoint)
    endPoint = percentBasedPointInBounds(
      from: CGPoint(
        x: absoluteStartPoint.x + radius,
        y: absoluteStartPoint.y + radius))
  }
}

extension GradientShapeItem {
  /// Converts the compact `[Double]` color components representation
  /// into an array of `CGColor`s and the location of those colors within the gradient
  fileprivate func colorConfiguration(
    from colorComponents: [Double])
    -> [(color: CGColor, location: CGFloat)]
  {
    precondition(
      colorComponents.count >= numberOfColors * 4,
      "Each color must have RGB components and a location component")

    var cgColors = [(color: CGColor, location: CGFloat)]()

    // Each group of four `Double` values represents a single `CGColor`,
    // and its relative location within the gradient.
    for colorIndex in 0..<numberOfColors {
      let colorStartIndex = colorIndex * 4

      let location = CGFloat(colorComponents[colorStartIndex])

      let color = CGColor.rgb(
        CGFloat(colorComponents[colorStartIndex + 1]),
        CGFloat(colorComponents[colorStartIndex + 2]),
        CGFloat(colorComponents[colorStartIndex + 3]))

      cgColors.append((color, location))
    }

    return cgColors
  }
}
