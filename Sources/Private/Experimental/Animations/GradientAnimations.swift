// Created by Cal Stephens on 1/7/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension GradientRenderLayer {

  // MARK: Internal

  /// Adds gradient-related animations to this layer, from the given `GradientFill`
  func addAnimations(for gradientFill: GradientFill, context: LayerAnimationContext) {
    // We have to set `colors` to a non-nil value with some valid number of colors
    // for the color animation below to have any effect
    colors = .init(
      repeating: CGColor.rgb(0, 0, 0),
      count: gradientFill.numberOfColors)

    addAnimation(
      for: .colors,
      keyframes: gradientFill.colors.keyframes,
      value: { colorComponents in
        gradientFill.colorConfiguration(from: colorComponents).map { $0.color }
      },
      context: context)

    addAnimation(
      for: .locations,
      keyframes: gradientFill.colors.keyframes,
      value: { colorComponents in
        gradientFill.colorConfiguration(from: colorComponents).map { $0.location }
      },
      context: context)

    switch gradientFill.gradientType {
    case .linear:
      addLinearGradientAnimations(for: gradientFill, context: context)
    case .radial:
      addRadialGradientAnimations(for: gradientFill, context: context)
    case .none:
      break
    }
  }

  // MARK: Private

  private func addLinearGradientAnimations(
    for gradientFill: GradientFill,
    context: LayerAnimationContext)
  {
    type = .axial

    addAnimation(
      for: .startPoint,
      keyframes: gradientFill.startPoint.keyframes,
      value: { absoluteStartPoint in
        percentBasedPointInBounds(from: absoluteStartPoint.pointValue)
      },
      context: context)

    addAnimation(
      for: .endPoint,
      keyframes: gradientFill.endPoint.keyframes,
      value: { absoluteEndPoint in
        percentBasedPointInBounds(from: absoluteEndPoint.pointValue)
      },
      context: context)
  }

  private func addRadialGradientAnimations(
    for gradientFill: GradientFill,
    context _: LayerAnimationContext)
  {
    type = .radial

    // To draw the correct gradients, we have to derive a custom `endPoint`
    // relative to the `startPoint` value. Since calculating the `endPoint`
    // at any given time requires knowing the current `startPoint`,
    // we can't allow them to animate separately.
    let absoluteStartPoint = gradientFill.startPoint.exactlyOneKeyframe.value.pointValue
    let absoluteEndPoint = gradientFill.endPoint.exactlyOneKeyframe.value.pointValue

    startPoint = percentBasedPointInBounds(from: absoluteStartPoint)

    let radius = absoluteStartPoint.distanceTo(absoluteEndPoint)
    endPoint = percentBasedPointInBounds(
      from: CGPoint(
        x: absoluteStartPoint.x + radius,
        y: absoluteStartPoint.y + radius))
  }
}

extension GradientFill {
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

      let location = colorComponents[colorStartIndex]

      let color = CGColor.rgb(
        colorComponents[colorStartIndex + 1],
        colorComponents[colorStartIndex + 2],
        colorComponents[colorStartIndex + 3])

      cgColors.append((color, location))
    }

    return cgColors
  }
}
