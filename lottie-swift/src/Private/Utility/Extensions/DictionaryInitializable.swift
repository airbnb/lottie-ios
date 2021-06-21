//
//  DictionaryInitializable.swift
//  lottie-swift
//
//  Created by Zak Forrest on 6/16/21.
//

import Foundation

enum InitializableError: Error {
  case invalidInput
}

protocol DictionaryInitializable {
  
  init(dictionary: [String: Any]) throws
  
}

protocol AnyInitializable {
  
  init(value: Any) throws
  
}

extension Dictionary {
  
  func valueFor<T>(key: Key) throws -> T {
    guard let value = self[key] as? T else {
      throw InitializableError.invalidInput
    }
    return value
  }
  
}

extension Array: AnyInitializable where Element == Double {
  
  init(value: Any) throws {
    guard let array = value as? [Double] else {
      throw InitializableError.invalidInput
    }
    self = array
  }
  
}
