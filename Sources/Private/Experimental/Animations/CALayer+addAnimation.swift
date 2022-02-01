// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

extension CALayer {

  // MARK: Internal

  /// Constructs a `CAKeyframeAnimation` that reflects the given keyframes,
  /// and adds it to this `CALayer`.
  @nonobjc
  func addAnimation<KeyframeValue, ValueRepresentation>(
    for property: LayerProperty<ValueRepresentation>,
    keyframes: ContiguousArray<Keyframe<KeyframeValue>>,
    value keyframeValueMapping: (KeyframeValue) -> ValueRepresentation,
    context: LayerAnimationContext)
  {
    if let customAnimation = customizedAnimation(for: property, context: context) {
      add(customAnimation, timedWith: context)
    }

    else if
      let defaultAnimation = defaultAnimation(
        for: property,
        keyframes: keyframes,
        value: keyframeValueMapping,
        context: context)
    {
      add(defaultAnimation, timedWith: context)
    }
  }

  // MARK: Private

  /// Constructs a `CAKeyframeAnimation` that reflects the given keyframes
  @nonobjc
  private func defaultAnimation<KeyframeValue, ValueRepresentation>(
    for property: LayerProperty<ValueRepresentation>,
    keyframes: ContiguousArray<Keyframe<KeyframeValue>>,
    value keyframeValueMapping: (KeyframeValue) -> ValueRepresentation,
    context: LayerAnimationContext)
    -> CAPropertyAnimation?
  {
    guard !keyframes.isEmpty else { return nil }

    let animation = CAKeyframeAnimation(keyPath: property.caLayerKeypath)

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
        animation.calculationMode = .discrete
      } else {
        LottieLogger.shared.warn("Mixed `isHold` / `!isHold` keyframes are currently unsupported")
      }
    }

    // Convert the list of `Keyframe<T>` into
    // the representation used by `CAKeyframeAnimation`
    var values = keyframes.map { keyframeModel in
      keyframeValueMapping(keyframeModel.value)
    }

    var keyTimes = keyframes.map { keyframeModel -> NSNumber in
      let progressTime = context.animation.progressTime(forFrame: keyframeModel.time, clamped: false)
      return NSNumber(value: Float(progressTime))
    }

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

    // Validate that we have the correct number of `values` and `keyTimes`
    switch animation.calculationMode {
    case .linear, .cubic:
      // From the documentation of `CAKeyframeAnimation.keyTimes`:
      //  - The number of elements in the keyTimes array
      //    should match the number of elements in the values property
      LottieLogger.shared.assert(
        values.count == keyTimes.count,
        "`values.count` must exactly equal `keyTimes.count`")

      LottieLogger.shared.assert(
        timingFunctions.count == (values.count - 1),
        "`timingFunctions.count` must exactly equal `values.count - 1`")

    case .discrete:
      // From the documentation of `CAKeyframeAnimation.keyTimes`:
      //  - If the calculationMode is set to discrete... the keyTimes array
      //    should have one more entry than appears in the values array.
      values.removeLast()

      LottieLogger.shared.assert(
        keyTimes.count == values.count + 1,
        "`keyTimes.count` must exactly equal `values.count + 1`")

    default:
      LottieLogger.shared.assertionFailure("""
      Unexpected keyframe calculation mode \(animation.calculationMode)
      """)
    }

    animation.values = values
    animation.keyTimes = keyTimes
    animation.timingFunctions = timingFunctions
    return animation
  }

  /// A `CAAnimation` that applies the custom value from the `AnyValueProvider`
  /// registered for this specific property's `AnimationKeypath`,
  /// if one has been registered using `AnimationView.setValueProvider(_:keypath:)`.
  @nonobjc
  private func customizedAnimation<ValueRepresentation>(
    for property: LayerProperty<ValueRepresentation>,
    context: LayerAnimationContext)
    -> CAPropertyAnimation?
  {
    guard
      let customizableProperty = property.customizableProperty,
      let customKeyframes = context.valueProviderStore.customKeyframes(
        of: customizableProperty,
        for: AnimationKeypath(keys: context.currentKeypath.keys + customizableProperty.name.map { $0.rawValue }))
    else { return nil }

    return defaultAnimation(
      for: property,
      keyframes: customKeyframes.keyframes,
      value: { $0 },
      context: context)
  }

}
