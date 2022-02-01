// Created by Cal Stephens on 1/28/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

// MARK: - Keyframes

enum Keyframes {
  /// Combines the given `[KeyframeGroup]` of `Keyframe<T>`s
  /// into a single `KeyframeGroup` of `Keyframe<[T]>`s
  /// if all of the `KeyframeGroup`s have the exact same animation timing
  static func combinedIfPossible<T>(_ groups: [KeyframeGroup<T>]) -> KeyframeGroup<[T]>? {
    guard
      !groups.isEmpty,
      groups.allSatisfy({ $0.hasSameTimingParameters(as: groups[0]) })
    else { return nil }

    var combinedKeyframes = ContiguousArray<Keyframe<[T]>>()

    for index in groups[0].keyframes.indices {
      let baseKeyframe = groups[0].keyframes[index]
      let combinedValues = groups.map { $0.keyframes[index].value }
      combinedKeyframes.append(baseKeyframe.withValue(combinedValues))
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
  /// Whether or not this keyframe has the same timing parameters as the given keyframe
  func hasSameTimingParameters<T>(as other: Keyframe<T>) -> Bool {
    time == other.time
      && isHold == other.isHold
      && inTangent == other.inTangent
      && outTangent == other.outTangent
      && spatialInTangent == other.spatialInTangent
      && spatialOutTangent == other.spatialOutTangent
  }
}
