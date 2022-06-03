// Created by Cal Stephens on 1/7/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

extension CAShapeLayer {
  /// Adds a `path` animation for the given `ShapeItem`
  @nonobjc
  func addAnimations(for shape: ShapeItem, context: LayerAnimationContext) throws {
    switch shape {
    case let customShape as Shape:
      try addAnimations(for: customShape.path, context: context)

    case let combinedShape as CombinedShapeItem:
      try addAnimations(for: combinedShape, context: context)

    case let ellipse as Ellipse:
      try addAnimations(for: ellipse, context: context)

    case let rectangle as Rectangle:
      try addAnimations(for: rectangle, context: context)

    case let star as Star:
      try addAnimations(for: star, context: context)

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
  func addAnimations(for trim: Trim, context: LayerAnimationContext) throws {
    let (strokeStartKeyframes, strokeEndKeyframes) = try trim.caShapeLayerKeyframes(context: context)

    try addAnimation(
      for: .strokeStart,
      keyframes: strokeStartKeyframes.keyframes,
      value: { strokeStart in
        // Lottie animation files express stoke trims as a numerical percentage value
        // (e.g. 25%, 50%, 100%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.25, 0.5, 1.0).
        CGFloat(strokeStart.cgFloatValue) / 100
      }, context: context)

    try addAnimation(
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

  // MARK: Fileprivate

  /// The `strokeStart` and `strokeEnd` keyframes to apply to a `CAShapeLayer`
  fileprivate func caShapeLayerKeyframes(context: LayerAnimationContext) throws
    -> (strokeStart: KeyframeGroup<Vector1D>, strokeEnd: KeyframeGroup<Vector1D>)
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
    
    // Adjust the keyframes to account for trim offsets if possible
    let adjustedStrokeStart = try adjustKeyframesForTrimOffsets(
      strokeKeyframes: strokeStart.keyframes,
      offsetKeyframes: offset.keyframes,
      context: context
    )
    
    let adjustedStrokeEnd = try adjustKeyframesForTrimOffsets(
      strokeKeyframes: strokeEnd.keyframes,
      offsetKeyframes: offset.keyframes,
      context: context
    )
    
    // Validate the adjusted keyframes and fallback on original if invalid
    if (adjustedStrokeStart + adjustedStrokeEnd).contains(where: {
      $0.value.cgFloatValue < 0 || $0.value.cgFloatValue > 100
    }) {
      try context.logCompatibilityIssue("""
        The CoreAnimation rendering engine doesn't support Trim offsets
        """)
      return (strokeStart: strokeStart, strokeEnd: strokeEnd)
    }
    
    return (
      strokeStart: KeyframeGroup<Vector1D>(keyframes: adjustedStrokeStart),
      strokeEnd: KeyframeGroup<Vector1D>(keyframes: adjustedStrokeEnd)
    )
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
  
  /// Adjusts a `KeyframeGroup` associated with a `strokeStart` or `strokeEnd` to account
  /// for trim offsets. The CoreAnimation rendering engine does not fully support trim offsets. If applying
  /// the offsets results in a `KeyframeGroup` with all values in the range `[0, 1]` then the offsets
  /// can be supported.
  private func adjustKeyframesForTrimOffsets(
    strokeKeyframes: ContiguousArray<Keyframe<Vector1D>>,
    offsetKeyframes: ContiguousArray<Keyframe<Vector1D>>,
    context: LayerAnimationContext
  ) throws -> ContiguousArray<Keyframe<Vector1D>> {
    guard
      !offsetKeyframes.isEmpty,
      offsetKeyframes.contains(where: { $0.value.cgFloatValue != 0 })
    else {
      return strokeKeyframes
    }
    
    // Map each keyframe time to its associated stroke/offset
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
          
      // Create the adjusted keyframe using the properties of the most recent keyframe
      let keyframePropertiesToUse = currentKeyframe.time >= currentOffset.time
        ? currentKeyframe
        : currentOffset
      
      let adjustedKeyframe = Keyframe<Vector1D>(
        value: Vector1D(adjustedValue),
        time: time,
        isHold: keyframePropertiesToUse.isHold,
        inTangent: keyframePropertiesToUse.inTangent,
        outTangent: keyframePropertiesToUse.outTangent,
        spatialInTangent: keyframePropertiesToUse.spatialInTangent,
        spatialOutTangent: keyframePropertiesToUse.spatialOutTangent
      )
      
      output.append(adjustedKeyframe)
    }
          
    return output
  }
}
