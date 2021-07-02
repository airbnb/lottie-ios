//
//  DashPattern.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/22/19.
//

import Foundation

enum DashElementType: String, Codable {
  case offset = "o"
  case dash = "d"
  case gap = "g"
}

final class DashElement: Codable, DictionaryInitializable {
  let type: DashElementType
  let value: KeyframeGroup<Vector1D>
  
  enum CodingKeys : String, CodingKey {
    case type = "n"
    case value = "v"
  }
  
  init(dictionary: [String : Any]) throws {
    let typeRawValue: String = try dictionary.valueFor(key: CodingKeys.type.rawValue)
    guard let type = DashElementType(rawValue: typeRawValue) else {
      throw InitializableError.invalidInput
    }
    self.type = type
    let valueDictionary: [String: Any] = try dictionary.valueFor(key: CodingKeys.value.rawValue)
    self.value = try KeyframeGroup<Vector1D>(dictionary: valueDictionary)
  }
}
