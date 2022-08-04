// Created by Cal Stephens on 1/28/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

// MARK: - Keyframes

enum Keyframes {

  // MARK: Internal

  /// Combines the given keyframe groups of `Keyframe<T>`s into a single keyframe group of
  /// of `Keyframe<[T]>`s if all of the `KeyframeGroup`s have the exact same animation timing
  static func combinedIfPossible<T>(_ allGroups: [KeyframeGroup<T>]) -> KeyframeGroup<[T]>? {
    combinedIfPossible(allGroups, makeCombinedResult: { index in
      allGroups.map { $0.valueForCombinedKeyframes(at: index) }
    })
  }

  /// Combines the given keyframe groups of `Keyframe<T>`s into a single keyframe group of
  /// of `Keyframe<[T]>`s if all of the `KeyframeGroup`s have the exact same animation timing
  static func combinedIfPossible<T1, T2, CombinedResult>(
    _ k1: KeyframeGroup<T1>,
    _ k2: KeyframeGroup<T2>,
    makeCombinedResult: (T1, T2) -> CombinedResult)
    -> KeyframeGroup<CombinedResult>?
  {
    combinedIfPossible(
      [k1, k2],
      makeCombinedResult: { index in
        makeCombinedResult(
          k1.valueForCombinedKeyframes(at: index),
          k2.valueForCombinedKeyframes(at: index))
      })
  }

  /// Combines the given keyframe groups of `Keyframe<T>`s into a single keyframe group of
  /// of `Keyframe<[T]>`s if all of the `KeyframeGroup`s have the exact same animation timing
  static func combinedIfPossible<T1, T2, T3, CombinedResult>(
    _ k1: KeyframeGroup<T1>,
    _ k2: KeyframeGroup<T2>,
    _ k3: KeyframeGroup<T3>,
    makeCombinedResult: (T1, T2, T3) -> CombinedResult)
    -> KeyframeGroup<CombinedResult>?
  {
    combinedIfPossible(
      [k1, k2, k3],
      makeCombinedResult: { index in
        makeCombinedResult(
          k1.valueForCombinedKeyframes(at: index),
          k2.valueForCombinedKeyframes(at: index),
          k3.valueForCombinedKeyframes(at: index))
      })
  }

  /// Combines the given keyframe groups of `Keyframe<T>`s into a single keyframe group of
  /// of `Keyframe<[T]>`s if all of the `KeyframeGroup`s have the exact same animation timing
  static func combinedIfPossible<T1, T2, T3, T4, T5, T6, T7, CombinedResult>(
    _ k1: KeyframeGroup<T1>,
    _ k2: KeyframeGroup<T2>,
    _ k3: KeyframeGroup<T3>,
    _ k4: KeyframeGroup<T4>,
    _ k5: KeyframeGroup<T5>,
    _ k6: KeyframeGroup<T6>,
    _ k7: KeyframeGroup<T7>,
    makeCombinedResult: (T1, T2, T3, T4, T5, T6, T7) -> CombinedResult)
    -> KeyframeGroup<CombinedResult>?
  {
    combinedIfPossible(
      [k1, k2, k3, k4, k5, k6, k7],
      makeCombinedResult: { index in
        makeCombinedResult(
          k1.valueForCombinedKeyframes(at: index),
          k2.valueForCombinedKeyframes(at: index),
          k3.valueForCombinedKeyframes(at: index),
          k4.valueForCombinedKeyframes(at: index),
          k5.valueForCombinedKeyframes(at: index),
          k6.valueForCombinedKeyframes(at: index),
          k7.valueForCombinedKeyframes(at: index))
      })
  }

  // MARK: Private

  /// Combines the given `[KeyframeGroup]` of `Keyframe<T>`s into a single `KeyframeGroup`
  /// of `Keyframe<CombinedResult>`s if all of the `KeyframeGroup`s have the exact same animation timing
  private static func combinedIfPossible<CombinedResult>(
    _ allGroups: [AnyKeyframeGroup],
    makeCombinedResult: (_ index: Int) -> CombinedResult)
    -> KeyframeGroup<CombinedResult>?
  {
    let untypedGroups = allGroups.map { $0.untyped }

    // Animations with no timing information (e.g. with just a single keyframe)
    // can be trivially combined with any other set of keyframes, so we don't need
    // to check those.
    let animatingKeyframes = untypedGroups.filter { $0.keyframes.count > 1 }

    guard
      !allGroups.isEmpty,
      animatingKeyframes.allSatisfy({ $0.hasSameTimingParameters(as: animatingKeyframes[0]) })
    else { return nil }

    var combinedKeyframes = ContiguousArray<Keyframe<CombinedResult>>()
    let baseKeyframes = (animatingKeyframes.first ?? untypedGroups[0]).keyframes

    for index in baseKeyframes.indices {
      let baseKeyframe = baseKeyframes[index]
      let combinedValue = makeCombinedResult(index)
      combinedKeyframes.append(baseKeyframe.withValue(combinedValue))
    }

    return KeyframeGroup(keyframes: combinedKeyframes)
  }

}

extension KeyframeGroup {
  /// Whether or not all of the keyframes in this `KeyframeGroup` have the same
  /// timing parameters as the corresponding keyframe in the other given `KeyframeGroup`
  func hasSameTimingParameters<T>(as other: KeyframeGroup<T>) -> Bool {
    guard keyframes.count == other.keyframes.count else {
      return false
    }

    return zip(keyframes, other.keyframes).allSatisfy {
      $0.hasSameTimingParameters(as: $1)
    }
  }
}

extension Keyframe {
  /// Whether or not this keyframe has the same timing parameters as the given keyframe,
  /// excluding `spatialInTangent` and `spatialOutTangent`.
  fileprivate func hasSameTimingParameters<T>(as other: Keyframe<T>) -> Bool {
    time == other.time
      && isHold == other.isHold
      && inTangent == other.inTangent
      && outTangent == other.outTangent
    // We intentionally don't compare spatial in/out tangents,
    // since those values are only used in very specific cases
    // (animating the x/y position of a layer), which aren't ever
    // combined in this way.
  }
}

extension KeyframeGroup {
  /// The value to use for a combined set of keyframes, for the given index
  fileprivate func valueForCombinedKeyframes(at index: Int) -> T {
    if keyframes.count == 1 {
      return keyframes[0].value
    } else {
      return keyframes[index].value
    }
  }
}
