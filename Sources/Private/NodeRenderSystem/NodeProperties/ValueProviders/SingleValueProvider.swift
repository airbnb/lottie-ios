//
//  SingleValueProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/30/19.
//

import Foundation
import QuartzCore

/// Returns a value for every frame.
final class SingleValueProvider<ValueType>: AnyValueProvider {

  // MARK: Lifecycle

  init(_ value: ValueType) {
    self.value = value
  }

  // MARK: Internal

  var value: ValueType {
    didSet {
      hasUpdate = true
    }
  }

  var valueType: Any.Type {
    ValueType.self
  }

  func hasUpdate(frame _: CGFloat) -> Bool {
    hasUpdate
  }

  func value(frame _: CGFloat) -> Any {
    hasUpdate = false
    return value
  }

  // MARK: Private

  private var hasUpdate: Bool = true
}
