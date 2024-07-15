//
//  AnyNodeProperty.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/30/19.
//

import CoreGraphics
import Foundation

// MARK: - AnyNodeProperty

/// A property of a node. The node property holds a provider and a container
protocol AnyNodeProperty {

  /// Returns true if the property needs to recompute its stored value
  func needsUpdate(frame: CGFloat) -> Bool

  /// Updates the property for the frame
  func update(frame: CGFloat)

  /// The stored value container for the property
  var valueContainer: any AnyValueContainer { get }

  /// The value provider for the property
  var valueProvider: any AnyValueProvider { get }

  /// The original value provider for the property
  var originalValueProvider: any AnyValueProvider { get }

  /// The Type of the value provider
  var valueType: Any.Type { get }

  /// Sets the value provider for the property.
  func setProvider(provider: any AnyValueProvider)
}

extension AnyNodeProperty {

  /// Returns the most recently computed value for the keypath, returns nil if property wasn't found
  func getValueOfType<T>() -> T? {
    valueContainer.value as? T
  }

  /// Returns the most recently computed value for the keypath, returns nil if property wasn't found
  func getValue() -> Any? {
    valueContainer.value
  }

}
