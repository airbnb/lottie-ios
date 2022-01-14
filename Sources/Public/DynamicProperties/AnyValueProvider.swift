//
//  AnyValueProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/30/19.
//

import CoreGraphics
import Foundation

// MARK: - AnyValueProvider

/**
 `AnyValueProvider` is a protocol that return animation data for a property at a
 given time. Every frame an `AnimationView` queries all of its properties and asks
 if their ValueProvider has an update. If it does the AnimationView will read the
 property and update that portion of the animation.

 Value Providers can be used to dynamically set animation properties at run time.
 */
public protocol AnyValueProvider {

  /// The Type of the value provider
  var valueType: Any.Type { get }

  /// The type-erased storage for this Value Provider
  var typeErasedStorage: ValueProviderStorage<Any> { get }

  /// Asks the provider if it has an update for the given frame.
  func hasUpdate(frame: AnimationFrameTime) -> Bool

}

extension AnyValueProvider {
  /// Asks the provider to update the container with its value for the frame.
  public func value(frame: AnimationFrameTime) -> Any {
    typeErasedStorage.value(frame: frame)
  }
}

// MARK: - ValueProvider

/// A base protocol for strongly-typed Value Providers
protocol ValueProvider: AnyValueProvider {
  associatedtype Value

  /// The strongly-typed storage for this Value Provider
  var storage: ValueProviderStorage<Value> { get }
}

extension ValueProvider {
  public var typeErasedStorage: ValueProviderStorage<Any> {
    switch storage {
    case .closure(let typedClosure):
      return .closure(typedClosure)
    case .singleValue(let typedValue):
      return .singleValue(typedValue)
    }
  }
}

// MARK: - ValueProviderStorage

/// The underlying storage of a `ValueProvider`
public enum ValueProviderStorage<T> {
  /// The value provider stores a single value that is used on all frames
  case singleValue(T)

  /// The value provider stores a closure that is invoked on every frame
  ///  - This is only supported by the legacy main-thread rendering engine
  case closure((AnimationFrameTime) -> T)

  // MARK: Internal

  var isSingleValue: Bool {
    switch self {
    case .singleValue:
      return true
    case .closure:
      return false
    }
  }

  func value(frame: AnimationFrameTime) -> T {
    switch self {
    case .singleValue(let value):
      return value
    case .closure(let closure):
      return closure(frame)
    }
  }
}
