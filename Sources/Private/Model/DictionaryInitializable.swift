//
//  DictionaryInitializable.swift
//  Lottie
//
//  Created by Marcelo Fabri on 5/5/22.
//

import Foundation

// MARK: - InitializableError

enum InitializableError: Error {
  case invalidInput
}

// MARK: - DictionaryInitializable

protocol DictionaryInitializable {

  init(dictionary: [String: Any]) throws

}

// MARK: - AnyInitializable

protocol AnyInitializable {

  init(value: Any) throws

}

extension Dictionary {

  @_disfavoredOverload
  func value<T>(for key: Key) throws -> T {
    guard let value = self[key] as? T else {
      throw InitializableError.invalidInput
    }
    return value
  }

  func value<T: AnyInitializable>(for key: Key) throws -> T {
    if let value = self[key] as? T {
      return value
    }

    if let value = self[key] {
      return try T(value: value)
    }

    throw InitializableError.invalidInput
  }

}

// MARK: - Array + AnyInitializable

extension Array: AnyInitializable where Element == Double {

  init(value: Any) throws {
    guard let array = value as? [Double] else {
      throw InitializableError.invalidInput
    }
    self = array
  }

}
