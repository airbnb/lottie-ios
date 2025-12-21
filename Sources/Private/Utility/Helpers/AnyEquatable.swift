// Created by miguel_jimenez on 8/2/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

// MARK: - AnyEquatable

struct AnyEquatable {
  init<T: Equatable>(_ value: T) {
    self.value = value
    equals = { $0 as? T == value }
  }

  private let value: Any
  private let equals: (Any) -> Bool

}

// MARK: Equatable

extension AnyEquatable: Equatable {
  static func ==(lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
    lhs.equals(rhs.value)
  }
}
