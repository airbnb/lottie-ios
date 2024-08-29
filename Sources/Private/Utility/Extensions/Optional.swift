//
//  Optional.swift
//
//
//  Created by BAHATTIN KOC on 29.08.2024.
//

public extension Optional {
  /// Checks if the optional value is nil.
  ///
  /// - Returns: `true` if the optional is nil; otherwise, `false`.
  ///
  /// Example:
  ///
  /// ```swift
  /// let optionalValue: Int? = nil
  /// let isValueNil = optionalValue.isNil // isValueNil will be true
  /// ```
  @inlinable var isNil: Bool { self == nil }

  /// Checks if the optional value is not nil.
  ///
  /// - Returns: `true` if the optional is not nil; otherwise, `false`.
  ///
  /// Example:
  ///
  /// ```swift
  /// let optionalValue: String? = "Hello, World!"
  /// let isValueNotNil = optionalValue.isNotNil // isValueNotNil will be true
  /// ```
  @inlinable var isNotNil: Bool { !isNil }

  /// Provides a default value when the optional is nil.
  ///
  /// - Parameter defaultValue: The value to use if the optional is nil.
  /// - Returns: The optional value if it is not nil, or the provided default value if the optional is nil.
  ///
  /// Example:
  ///
  /// ```swift
  /// let optionalInt: Int? = nil
  /// let result = optionalInt.or(42) // result will be 42
  /// ```
  @inlinable func or(_ defaultValue: Wrapped) -> Wrapped {
    self ?? defaultValue
  }

  /// Provides a default value when the optional is nil, or the provided default value if it is nil.
  ///
  /// - Parameter defaultValue: The value to use if the optional is nil. This value can be nil.
  /// - Returns: The optional value if it is not nil, or the provided default value if the optional is nil.
  ///
  /// Example:
  ///
  /// ```swift
  /// let optionalInt: Int? = nil
  /// let result = optionalInt.or(42) // result will be 42
  ///
  /// let optionalString: String? = nil
  /// let result = optionalString.or(nil) // result will be nil
  /// ```
  @inlinable func or(_ defaultValue: Wrapped?) -> Wrapped? {
      self ?? defaultValue
  }
}

public extension Optional where Wrapped == Bool {
  /// Provides `true` when the optional is nil.
  ///
  /// - Returns: `true` if the optional is nil; otherwise, the value of the optional bool.
  ///
  /// Example:
  ///
  /// ```swift
  /// let optionalBool: Bool? = nil
  /// let result = optionalBool.orTrue // result will be true
  /// ```
  @inlinable var orTrue: Bool { self.or(true) }

  /// Provides `false` when the optional is nil.
  ///
  /// - Returns: `false` if the optional is nil; otherwise, the value of the optional bool.
  ///
  /// Example:
  ///
  /// ```swift
  /// let optionalBool: Bool? = nil
  /// let result = optionalBool.orFalse // result will be false
  /// ```
  @inlinable var orFalse: Bool { self.or(false) }
}

public extension Optional where Wrapped == String {
  /// Checks if the optional string is either nil or consists only of whitespace characters.
  ///
  /// - Returns: `true` if the optional string is nil or contains only whitespace characters or is empty; otherwise, `false`.
  ///
  /// Example:
  ///
  /// ```swift
  /// let nilString: String? = nil
  /// let blankString: String? = "   "
  /// let nonBlankString: String? = "Hello, World!"
  ///
  /// let isNilOrBlank = nilString.isNilOrBlank // isNilOrBlank will be true
  /// let isBlank = blankString.isNilOrBlank // isBlank will be true
  /// let isNonBlank = nonBlankString.isNilOrBlank // isNonBlank will be false
  /// ```
  @inlinable var isNilOrBlank: Bool { (self?.isBlank).orTrue }
}

public extension Optional where Wrapped: Collection {
  /// Checks if the optional collection is either nil or empty.
  ///
  /// - Returns: `true` if the optional collection is nil or empty; otherwise, `false`.
  ///
  /// Example:
  ///
  /// ```swift
  /// let optionalArray: [Int]? = []
  /// let result = optionalArray.isNilOrEmpty // result will be true
  /// ```
  var isNilOrEmpty: Bool { (self?.isEmpty).orTrue }
}

public extension Optional where Wrapped: RangeReplaceableCollection {
  /// Provides an empty collection when the optional is nil.
  ///
  /// - Returns: An empty collection if the optional is nil; otherwise, the value of the optional collection.
  ///
  /// Example:
  ///
  /// ```swift
  /// let optionalCollection: String? = nil
  /// let result = optionalCollection.orEmpty // result will be an empty string
  /// ```
  @inlinable var orEmpty: Wrapped { self.or(Wrapped()) }
}

public extension Optional where Wrapped: AdditiveArithmetic {
  /// Provides `zero` when the optional is nil.
  ///
  /// - Returns: `zero` if the optional is nil; otherwise, the value of the optional.
  ///
  /// Example:
  ///
  /// ```swift
  /// let optionalInt: Int? = nil
  /// let result = Int.orZero // result will be zero
  /// ```
  @inlinable var orZero: Wrapped { self.or(.zero) }
}

public extension Optional where Wrapped: ExpressibleByDictionaryLiteral {
  /// Provides an empty dictionary when the optional is nil.
  ///
  /// - Returns: An empty dictionary if the optional is nil; otherwise, the value of the optional dictionary.
  ///
  ///  /// Example:
  ///
  /// ```swift
  /// let optionalCollection: [String: Any]? = nil
  /// let result = optionalCollection.orEmpty // result will be an empty string
  /// ```
  @inlinable var orEmpty: Wrapped { self.or([:]) }
}
