// Created by Cal Stephens on 1/7/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds a `path` animation for the given `ShapeItem`
  @nonobjc
  func addAnimations(
    for shape: ShapeItem,
    context: LayerAnimationContext,
    pathMultiplier: PathMultiplier) throws
  {
    switch shape {
    case let customShape as Shape:
      try addAnimations(for: customShape.path, context: context, pathMultiplier: pathMultiplier)

    case let combinedShape as CombinedShapeItem:
      try addAnimations(for: combinedShape, context: context, pathMultiplier: pathMultiplier)

    case let ellipse as Ellipse:
      try addAnimations(for: ellipse, context: context, pathMultiplier: pathMultiplier)

    case let rectangle as Rectangle:
      try addAnimations(for: rectangle, context: context, pathMultiplier: pathMultiplier)

    case let star as Star:
      try addAnimations(for: star, context: context, pathMultiplier: pathMultiplier)

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
  func addAnimations(for trim: Trim, context: LayerAnimationContext) throws -> PathMultiplier {
    let (strokeStartKeyframes, strokeEndKeyframes, pathMultiplier) = try trim.caShapeLayerKeyframes(context: context)

    try addAnimation(
      for: .strokeStart,
      keyframes: strokeStartKeyframes.keyframes,
      value: { strokeStart in
        // Lottie animation files express stoke trims as a numerical percentage value
        // (e.g. 25%, 50%, 100%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.25, 0.5, 1.0).
        CGFloat(strokeStart.cgFloatValue) / CGFloat(pathMultiplier) / 100
      }, context: context)

    try addAnimation(
      for: .strokeEnd,
      keyframes: strokeEndKeyframes.keyframes,
      value: { strokeEnd in
        // Lottie animation files express stoke trims as a numerical percentage value
        // (e.g. 25%, 50%, 100%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.25, 0.5, 1.0).
        CGFloat(strokeEnd.cgFloatValue) / CGFloat(pathMultiplier) / 100
      }, context: context)

    return pathMultiplier
  }
}

/// The number of times that a `CGPath` needs to be duplicated in order to support the animation's `Trim` keyframes
typealias PathMultiplier = Int

extension Trim {

  // MARK: Fileprivate

  /// The `strokeStart` and `strokeEnd` keyframes to apply to a `CAShapeLayer`,
  /// plus a `pathMultiplier` that should be applied to the layer's `path` so that
  /// trim values larger than 100% can be displayed properly.
  fileprivate func caShapeLayerKeyframes(context: LayerAnimationContext) throws
    -> (strokeStart: KeyframeGroup<Vector1D>, strokeEnd: KeyframeGroup<Vector1D>, pathMultiplier: PathMultiplier)
  {
    let strokeStart: KeyframeGroup<Vector1D>
    let strokeEnd: KeyframeGroup<Vector1D>

    // CAShapeLayer requires strokeStart to be less than strokeEnd. This
    // isn't required by the Lottie schema, so some animations may have
    // strokeStart and strokeEnd flipped. If we detect this is the case,
    // then swap them.
    if startValueIsAlwaysGreaterThanEndValue() {
      strokeStart = end
      strokeEnd = start
    } else {
      strokeStart = start
      strokeEnd = end
    }

    // If there are no offsets, then the stroke values can be used as-is
    guard
      !offset.keyframes.isEmpty,
      offset.keyframes.contains(where: { $0.value.cgFloatValue != 0 })
    else {
      return (strokeStart, strokeEnd, 1)
    }

    // Otherwise, adjust the stroke values to account for the offsets
    // 1. Interpolate the keyframes so they are all on a linear timing function
    // 2. Merge by summing the stroke values with the offset values
    let interpolatedStrokeStart = strokeStart.manuallyInterpolateKeyframes()
    let interpolatedStrokeEnd = strokeEnd.manuallyInterpolateKeyframes()
    let interpolatedStrokeOffset = offset.manuallyInterpolateKeyframes()

    let adjustedStrokeStart = try adjustKeyframesForTrimOffsets(
      strokeKeyframes: interpolatedStrokeStart,
      offsetKeyframes: interpolatedStrokeOffset,
      context: context)

    let adjustedStrokeEnd = try adjustKeyframesForTrimOffsets(
      strokeKeyframes: interpolatedStrokeEnd,
      offsetKeyframes: interpolatedStrokeOffset,
      context: context)

    // If maximum stroke value is larger than 100%, then we have to create copies of the path
    // so the total path length includes the maximum stroke
    let maximumStroke = adjustedStrokeEnd.map { $0.value.cgFloatValue }.max() ?? 100
    let pathMultiplier = Int(ceil(maximumStroke / 100.0))

    return (
      strokeStart: KeyframeGroup<Vector1D>(keyframes: adjustedStrokeStart),
      strokeEnd: KeyframeGroup<Vector1D>(keyframes: adjustedStrokeEnd),
      pathMultiplier: pathMultiplier)
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

  /// Adjusted stroke keyframes to account for offset keyframes by merging them into a single keyframe collection
  ///
  /// Since stroke keyframes and offset keyframes can be defined on different animation curves, they must be
  /// manually interpolated prior to invoking this method. Manually interpolating the keyframes will redefine both
  /// keyframe groups such that they can be interpolated linearly.
  ///
  /// - Precondition: The keyframes must be interpolated using `KeyframeGroup.manuallyInterpolateKeyframes()`
  private func adjustKeyframesForTrimOffsets(
    strokeKeyframes: ContiguousArray<Keyframe<Vector1D>>,
    offsetKeyframes: ContiguousArray<Keyframe<Vector1D>>,
    context _: LayerAnimationContext) throws -> ContiguousArray<Keyframe<Vector1D>>
  {
    guard
      !strokeKeyframes.isEmpty,
      !offsetKeyframes.isEmpty
    else {
      return strokeKeyframes
    }

    // Map each time to its corresponding stroke/offset keyframe
    var timeMap = [AnimationFrameTime: [Keyframe<Vector1D>?]]()
    for stroke in strokeKeyframes {
      timeMap[stroke.time] = [stroke, nil]
    }
    for offset in offsetKeyframes {
      if var existing = timeMap[offset.time] {
        existing[1] = offset
        timeMap[offset.time] = existing
      } else {
        timeMap[offset.time] = [nil, offset]
      }
    }

    // Each time will be mapped to a new, adjusted keyframe
    var output = ContiguousArray<Keyframe<Vector1D>>()
    var lastKeyframe: Keyframe<Vector1D>?
    var lastOffset: Keyframe<Vector1D>?

    for (time, values) in timeMap.sorted(by: { $0.0 < $1.0 }) {
      // Extract keyframe/offset associated with this timestamp
      let keyframe = values[0]
      let offset = values[1]
      lastKeyframe = keyframe ?? lastKeyframe
      lastOffset = offset ?? lastOffset

      guard let currentKeyframe = lastKeyframe else {
        // No keyframes are output until the first keyframe occurs
        continue
      }

      guard let currentOffset = lastOffset else {
        // Scalar isHold keyframes are not output as they offset the offset keyframes
        if !(strokeKeyframes.count == 1 && currentKeyframe.isHold) {
          output.append(currentKeyframe)
        }
        continue
      }

      // Compute the adjusted value by converting the offset value to a stroke value
      let strokeValue = currentKeyframe.value.value
      let offsetValue = currentOffset.value.value
      let adjustedValue = strokeValue + (offsetValue / 360 * 100)

      // The tangent values are all `nil` as the keyframes should have been manually interpolated
      let adjustedKeyframe = Keyframe<Vector1D>(
        value: Vector1D(adjustedValue),
        time: time,
        isHold: currentKeyframe.isHold,
        inTangent: nil,
        outTangent: nil,
        spatialInTangent: nil,
        spatialOutTangent: nil)

      output.append(adjustedKeyframe)
    }

    return output
  }
}
