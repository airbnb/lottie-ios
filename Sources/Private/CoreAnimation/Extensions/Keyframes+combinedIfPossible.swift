// Created by Cal Stephens on 1/28/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

// MARK: - Keyframes

enum Keyframes {
  /// Combines the given keyframe groups of `Keyframe<T>`s into a single `KeyframeGroup`
  /// of `Keyframe<CombinedResult>`s if all of the `KeyframeGroup`s have the exact same animation timing
  static func combinedIfPossible<CombinedResult>(
    _ allGroups: AnyKeyframeGroup...,
    makeCombinedResult: ([Any]) -> CombinedResult)
    -> KeyframeGroup<CombinedResult>?
  {
    combinedIfPossible(
      allGroups.map { $0.untyped },
      makeCombinedResult: makeCombinedResult)
  }

  /// Combines the given `[KeyframeGroup]` of `Keyframe<T>`s into a single `KeyframeGroup`
  /// of `Keyframe<[T]>`s if all of the `KeyframeGroup`s have the exact same animation timing
  static func combinedIfPossible<T>(_ allGroups: [KeyframeGroup<T>]) -> KeyframeGroup<[T]>? {
    combinedIfPossible(allGroups, makeCombinedResult: { $0 })
  }

  /// Combines the given `[KeyframeGroup]` of `Keyframe<T>`s into a single `KeyframeGroup`
  /// of `Keyframe<CombinedResult>`s if all of the `KeyframeGroup`s have the exact same animation timing
  static func combinedIfPossible<T, CombinedResult>(
    _ allGroups: [KeyframeGroup<T>],
    makeCombinedResult: ([T]) -> CombinedResult)
    -> KeyframeGroup<CombinedResult>?
  {
    // Animations with no timing information (e.g. with just a single keyframe)
    // can be trivially combined with any other set of keyframes, so we don't need
    // to check those.
    let animatingKeyframes = allGroups.filter { $0.keyframes.count > 1 }

    guard
      !allGroups.isEmpty,
      animatingKeyframes.allSatisfy({ $0.hasSameTimingParameters(as: animatingKeyframes[0]) })
    else { return nil }

    var combinedKeyframes = ContiguousArray<Keyframe<CombinedResult>>()
    let baseKeyframes = (animatingKeyframes.first ?? allGroups[0]).keyframes

    for index in baseKeyframes.indices {
      let baseKeyframe = baseKeyframes[index]
      let combinedValues = allGroups.map { otherKeyframes -> T in
        if otherKeyframes.keyframes.count == 1 {
          return otherKeyframes.keyframes[0].value
        } else {
          return otherKeyframes.keyframes[index].value
        }
      }
      combinedKeyframes.append(baseKeyframe.withValue(makeCombinedResult(combinedValues)))
    }

    return KeyframeGroup(keyframes: combinedKeyframes)
  }

  /// Combines the given `[KeyframeGroup?]` of `Keyframe<T>`s
  /// into a single `KeyframeGroup` of `Keyframe<[T]>`s
  /// if all of the `KeyframeGroup`s have the exact same animation timing
  static func combinedIfPossible<T>(_ groups: [KeyframeGroup<T>?]) -> KeyframeGroup<[T]>? {
    let nonOptionalGroups = groups.compactMap { $0 }
    guard nonOptionalGroups.count == groups.count else { return nil }
    return combinedIfPossible(nonOptionalGroups)
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
