// Created by miguel_jimenez on 8/2/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Foundation

struct AnyEquatable {
  private let value: Any
  private let equals: (Any) -> Bool

  init<T: Equatable>(_ value: T) {
    self.value = value
    self.equals = { ($0 as? T == value) }
  }
}

extension AnyEquatable: Equatable {
  static func ==(lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
    return lhs.equals(rhs.value)
  }
}
