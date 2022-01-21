// Created by Cal Stephens on 1/13/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ValueProviderStore

/// Registration and storage for `AnyValueProvider`s that can dynamically
/// provide custom values for `AnimationKeypath`s within an `Animation`.
final class ValueProviderStore {

  // MARK: Internal

  /// Registers an `AnyValueProvider` for the given `AnimationKeypath`
  func setValueProvider(_ valueProvider: AnyValueProvider, keypath: AnimationKeypath) {
    LottieLogger.shared.assert(
      valueProvider.typeErasedStorage.isSupportedByCoreAnimationRenderingEngine,
      "The Core Animation rendering engine doesn't support Value Providers that vend a closure.")

    // TODO: Support wildcard path elements
    LottieLogger.shared.assert(
      !keypath.fullPath.contains("*"),
      "The new rendering engine currently does not support wildcard elements")

    // TODO: Support more value types
    LottieLogger.shared.assert(
      keypath.keys.last == PropertyName.color.rawValue,
      "The new rendering engine currently only supports customizing color values")

    valueProviders[keypath] = valueProvider
  }

  // Retrieves the custom value keyframes for the given property,
  // if an `AnyValueProvider` was registered for the given keypath.
  func customKeyframes<Value>(
    of customizableProperty: CustomizableProperty<Value>,
    for keypath: AnimationKeypath)
    -> KeyframeGroup<Value>?
  {
    guard let anyValueProvider = valueProviders[keypath] else {
      return nil
    }

    // Retrieve the type-erased keyframes from the custom `ValueProvider`
    let typeErasedKeyframes: KeyframeGroup<Any>
    switch anyValueProvider.typeErasedStorage {
    case .singleValue(let typeErasedValue):
      typeErasedKeyframes = KeyframeGroup(typeErasedValue)

    case .keyframes(let keyframes, _):
      typeErasedKeyframes = keyframes

    case .closure:
      LottieLogger.shared.assertionFailure("""
      The new rendering engine only supports Value Providers with a single fixed value
      """)
      return nil
    }

    // Convert the type-erased keyframe values using this `CustomizableProperty`'s conversion closure
    let typedKeyframes = typeErasedKeyframes.compactMap { typeErasedValue -> Value? in
      let convertedValue = customizableProperty.conversion(typeErasedValue)

      LottieLogger.shared.assert(
        convertedValue != nil,
        "Could not convert value of type \(type(of: typeErasedValue)) to expected type \(Value.self)")

      return convertedValue
    }

    // Verify that all of the keyframes were successfully converted to the expected type
    guard typedKeyframes.keyframes.count == typeErasedKeyframes.keyframes.count else {
      return nil
    }

    return typedKeyframes
  }

  // MARK: Private

  private var valueProviders = [AnimationKeypath: AnyValueProvider]()

}

extension AnyValueProviderStorage {
  /// Whether or not this type of value provider is supported
  /// by the new Core Animation rendering engine
  var isSupportedByCoreAnimationRenderingEngine: Bool {
    switch self {
    case .singleValue, .keyframes:
      return true
    case .closure:
      return false
    }
  }
}
