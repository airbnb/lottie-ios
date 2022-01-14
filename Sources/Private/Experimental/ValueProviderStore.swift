// Created by Cal Stephens on 1/13/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

/// Registration and storage for `AnyValueProvider`s that can dynamically
/// provide custom values for `AnimationKeypath`s within an `Animation`.
final class ValueProviderStore {

  // MARK: Internal

  /// Registers an `AnyValueProvider` for the given `AnimationKeypath`
  func setValueProvider(_ valueProvider: AnyValueProvider, keypath: AnimationKeypath) {
    LottieLogger.shared.assert(
      valueProvider.typeErasedStorage.isSingleValue,
      "The new rendering engine only supports Value Providers with a single fixed value")

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

  // Retrieves the custom value for the given property,
  // if an `AnyValueProvider` was registered for the given keypath.
  func customValue<Value>(
    of customizableProperty: CustomizableProperty<Value>,
    for keypath: AnimationKeypath)
    -> Value?
  {
    guard let anyValueProvider = valueProviders[keypath] else {
      return nil
    }

    switch anyValueProvider.typeErasedStorage {
    case .singleValue(let typeErasedValue):
      let convertedValue = customizableProperty.conversion(typeErasedValue)

      LottieLogger.shared.assert(
        convertedValue != nil,
        "Could not convert value of type \(type(of: typeErasedValue)) to expected type \(Value.self)")

      return convertedValue

    case .closure:
      LottieLogger.shared.assertionFailure("""
      The new rendering engine only supports Value Providers with a single fixed value
      """)
      return nil
    }
  }

  // MARK: Private

  private var valueProviders = [AnimationKeypath: AnyValueProvider]()

}
