// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CALayer {

  // MARK: Internal

  /// Constructs a `CAKeyframeAnimation` that reflects the given keyframes,
  /// and adds it to this `CALayer`.
  @nonobjc
  func addAnimation<KeyframeValue, ValueRepresentation: Equatable>(
    for property: LayerProperty<ValueRepresentation>,
    keyframes: ContiguousArray<Keyframe<KeyframeValue>>,
    value keyframeValueMapping: (KeyframeValue) throws -> ValueRepresentation,
    context: LayerAnimationContext)
    throws
  {
    if let customAnimation = try customizedAnimation(for: property, context: context) {
      add(customAnimation, timedWith: context)
    }

    else if
      let defaultAnimation = try defaultAnimation(
        for: property,
        keyframes: keyframes,
        value: keyframeValueMapping,
        context: context)
    {
      add(defaultAnimation, timedWith: context)
    }
  }

  // MARK: Private

  /// Constructs a `CAAnimation` that reflects the given keyframes
  ///  - If the value can be applied directly to the CALayer using KVC,
  ///    then no `CAAnimation` will be created and the value will be applied directly.
  @nonobjc
  private func defaultAnimation<KeyframeValue, ValueRepresentation>(
    for property: LayerProperty<ValueRepresentation>,
    keyframes: ContiguousArray<Keyframe<KeyframeValue>>,
    value keyframeValueMapping: (KeyframeValue) throws -> ValueRepresentation,
    context: LayerAnimationContext)
    throws
    -> CAPropertyAnimation?
  {
    guard !keyframes.isEmpty else { return nil }

    // If there is exactly one keyframe value, we can improve performance
    // by applying that value directly to the layer instead of creating
    // a relatively expensive `CAKeyframeAnimation`.
    if keyframes.count == 1 {
      let keyframeValue = try keyframeValueMapping(keyframes[0].value)

      // If the keyframe value is the same as the layer's default value for this property,
      // then we can just ignore this set of keyframes.
      if keyframeValue == property.defaultValue {
        return nil
      }

      // If the property on the CALayer being animated hasn't been modified from the default yet,
      // then we can apply the keyframe value directly to the layer using KVC instead
      // of creating a `CAAnimation`.
      if
        let defaultValue = property.defaultValue,
        defaultValue == value(forKey: property.caLayerKeypath) as? ValueRepresentation
      {
        setValue(keyframeValue, forKeyPath: property.caLayerKeypath)
        return nil
      }

      // Otherwise, we still need to create a `CAAnimation`, but we can
      // create a simple `CABasicAnimation` that is still less expensive
      // than computing a `CAKeyframeAnimation`.
      let animation = CABasicAnimation(keyPath: property.caLayerKeypath)
      animation.fromValue = keyframeValue
      animation.toValue = keyframeValue
      return animation
    }

    return try keyframeAnimation(
      for: property,
      keyframes: keyframes,
      value: keyframeValueMapping,
      context: context)
  }

  /// A `CAAnimation` that applies the custom value from the `AnyValueProvider`
  /// registered for this specific property's `AnimationKeypath`,
  /// if one has been registered using `AnimationView.setValueProvider(_:keypath:)`.
  @nonobjc
  private func customizedAnimation<ValueRepresentation>(
    for property: LayerProperty<ValueRepresentation>,
    context: LayerAnimationContext)
    throws
    -> CAPropertyAnimation?
  {
    guard
      let customizableProperty = property.customizableProperty,
      let customKeyframes = try context.valueProviderStore.customKeyframes(
        of: customizableProperty,
        for: AnimationKeypath(keys: context.currentKeypath.keys + customizableProperty.name.map { $0.rawValue }),
        context: context)
    else { return nil }

    // Since custom animations are overriding an existing animation,
    // we always have to create a CAKeyframeAnimation for these instead of
    // letting `defaultAnimation(...)` try to apply the value using KVC.
    return try keyframeAnimation(
      for: property,
      keyframes: customKeyframes.keyframes,
      value: { $0 },
      context: context)
  }

  /// Creates a `CAKeyframeAnimation` for the given keyframes
  private func keyframeAnimation<KeyframeValue, ValueRepresentation>(
    for property: LayerProperty<ValueRepresentation>,
    keyframes: ContiguousArray<Keyframe<KeyframeValue>>,
    value keyframeValueMapping: (KeyframeValue) throws -> ValueRepresentation,
    context: LayerAnimationContext)
    throws
    -> CAKeyframeAnimation
  {
    // Convert the list of `Keyframe<T>` into
    // the representation used by `CAKeyframeAnimation`
    var keyTimes = keyframes.map { keyframeModel -> NSNumber in
      NSNumber(value: Float(context.progressTime(for: keyframeModel.time)))
    }

    var timingFunctions = self.timingFunctions(for: keyframes)
    let calculationMode = try self.calculationMode(for: keyframes, context: context)

    let animation = CAKeyframeAnimation(keyPath: property.caLayerKeypath)

    // Position animations define a `CGPath` curve that should be followed,
    // instead of animating directly between keyframe point values.
    if property.caLayerKeypath == LayerProperty<CGPoint>.position.caLayerKeypath {
      animation.path = try path(keyframes: keyframes, value: { value in
        guard let point = try keyframeValueMapping(value) as? CGPoint else {
          context.logger.assertionFailure("Cannot create point from keyframe with value \(value)")
          return .zero
        }

        return point
      })
    }

    // All other types of keyframes provide individual values that are interpolated by Core Animation
    else {
      var values = try keyframes.map { keyframeModel in
        try keyframeValueMapping(keyframeModel.value)
      }

      validate(
        values: &values,
        keyTimes: &keyTimes,
        timingFunctions: &timingFunctions,
        for: calculationMode,
        context: context)

      animation.values = values
    }

    animation.calculationMode = calculationMode
    animation.keyTimes = keyTimes
    animation.timingFunctions = timingFunctions
    return animation
  }

  /// The `CAAnimationCalculationMode` that should be used for a `CAKeyframeAnimation`
  /// animating the given keyframes
  private func calculationMode<KeyframeValue>(
    for keyframes: ContiguousArray<Keyframe<KeyframeValue>>,
    context: LayerAnimationContext)
    throws
    -> CAAnimationCalculationMode
  {
    // Animations using `isHold` should use `CAAnimationCalculationMode.discrete`
    //
    //  - Since we currently only create a single `CAKeyframeAnimation`,
    //    we can currently only correctly support animations where
    //    `isHold` is either always `true` or always `false`
    //    (this requirement doesn't apply to the first/last keyframes).
    //
    //  - We should be able to support this in the future by creating multiple
    //    `CAKeyframeAnimation`s with different `calculationMode`s and
    //    playing them sequentially.
    //
    let intermediateKeyframes = keyframes.dropFirst().dropLast()
    if intermediateKeyframes.contains(where: \.isHold) {
      if intermediateKeyframes.allSatisfy(\.isHold) {
        return .discrete
      } else {
        try context.logCompatibilityIssue("Mixed `isHold` / `!isHold` keyframes are currently unsupported")
      }
    }

    return .linear
  }

  /// `timingFunctions` to apply to a `CAKeyframeAnimation` animating the given keyframes
  private func timingFunctions<KeyframeValue>(
    for keyframes: ContiguousArray<Keyframe<KeyframeValue>>)
    -> [CAMediaTimingFunction]
  {
    // Compute the timing function between each keyframe and the subsequent keyframe
    var timingFunctions: [CAMediaTimingFunction] = []

    for (index, keyframe) in keyframes.enumerated()
      where index != keyframes.indices.last
    {
      let nextKeyframe = keyframes[index + 1]

      let controlPoint1 = keyframe.outTangent?.pointValue ?? .zero
      let controlPoint2 = nextKeyframe.inTangent?.pointValue ?? CGPoint(x: 1, y: 1)

      timingFunctions.append(CAMediaTimingFunction(
        controlPoints:
        Float(controlPoint1.x),
        Float(controlPoint1.y),
        Float(controlPoint2.x),
        Float(controlPoint2.y)))
    }

    return timingFunctions
  }

  /// Creates a `CGPath` for the given `position` keyframes,
  /// which accounts for `spatialInTangent`s and `spatialOutTangents`
  private func path<KeyframeValue>(
    keyframes positionKeyframes: ContiguousArray<Keyframe<KeyframeValue>>,
    value keyframeValueMapping: (KeyframeValue) throws -> CGPoint) rethrows
    -> CGPath {
    let path = CGMutablePath()

    for (index, keyframe) in positionKeyframes.enumerated() {
      if index == positionKeyframes.indices.first {
        path.move(to: try keyframeValueMapping(keyframe.value))
      }

      if index != positionKeyframes.indices.last {
        let nextKeyframe = positionKeyframes[index + 1]

        if
          let controlPoint1 = keyframe.spatialOutTangent?.pointValue,
          let controlPoint2 = nextKeyframe.spatialInTangent?.pointValue,
          controlPoint1 != .zero,
          controlPoint2 != .zero
        {
          path.addCurve(
            to: try keyframeValueMapping(nextKeyframe.value),
            control1: try keyframeValueMapping(keyframe.value) + controlPoint1,
            control2: try keyframeValueMapping(nextKeyframe.value) + controlPoint2)
        }

        else {
          path.addLine(to: try keyframeValueMapping(nextKeyframe.value))
        }
      }
    }

    path.closeSubpath()
    return path
  }

  /// Validates that the requirements of the `CAKeyframeAnimation` API are met correctly
  private func validate<ValueRepresentation>(
    values: inout [ValueRepresentation],
    keyTimes: inout [NSNumber],
    timingFunctions: inout [CAMediaTimingFunction],
    for calculationMode: CAAnimationCalculationMode,
    context: LayerAnimationContext)
  {
    // Validate that we have correct start (0.0) and end (1.0) keyframes.
    // From the documentation of `CAKeyframeAnimation.keyTimes`:
    //  - The first value in the `keyTimes` array must be 0.0 and the last value must be 1.0.
    if keyTimes.first != 0.0 {
      keyTimes.insert(0.0, at: 0)
      values.insert(values[0], at: 0)
      timingFunctions.insert(CAMediaTimingFunction(name: .linear), at: 0)
    }

    if keyTimes.last != 1.0 {
      keyTimes.append(1.0)
      values.append(values.last!)
      timingFunctions.append(CAMediaTimingFunction(name: .linear))
    }

    switch calculationMode {
    case .linear, .cubic:
      // From the documentation of `CAKeyframeAnimation.keyTimes`:
      //  - The number of elements in the keyTimes array
      //    should match the number of elements in the values property
      context.logger.assert(
        values.count == keyTimes.count,
        "`values.count` must exactly equal `keyTimes.count`")

      context.logger.assert(
        timingFunctions.count == (values.count - 1),
        "`timingFunctions.count` must exactly equal `values.count - 1`")

    case .discrete:
      // From the documentation of `CAKeyframeAnimation.keyTimes`:
      //  - If the calculationMode is set to discrete... the keyTimes array
      //    should have one more entry than appears in the values array.
      values.removeLast()

      context.logger.assert(
        keyTimes.count == values.count + 1,
        "`keyTimes.count` must exactly equal `values.count + 1`")

    default:
      context.logger.assertionFailure("""
        Unexpected keyframe calculation mode \(calculationMode)
        """)
    }
  }

}
