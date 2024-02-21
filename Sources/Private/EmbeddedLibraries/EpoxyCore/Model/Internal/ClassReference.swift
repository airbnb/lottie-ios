// Created by Cal Stephens on 10/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

// MARK: - ClassReference

/// A `Hashable` value wrapper around an `AnyClass` value
///  - Unlike `ObjectIdentifier(class)`, `ClassReference(class)`
///    preserves the `AnyClass` value and is more human-readable.
internal struct ClassReference {
  internal init(_ class: AnyClass) {
    self.class = `class`
  }

  internal let `class`: AnyClass
}

// MARK: Equatable

extension ClassReference: Equatable {
  internal static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
    ObjectIdentifier(lhs.class) == ObjectIdentifier(rhs.class)
  }
}

// MARK: Hashable

extension ClassReference: Hashable {
  internal func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(`class`))
  }
}

// MARK: CustomStringConvertible

extension ClassReference: CustomStringConvertible {
  internal var description: String {
    String(describing: `class`)
  }
}
