//
//  Font.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

import Foundation

final class Font: Codable, DictionaryInitializable {
  
  let name: String
  let familyName: String
  let style: String
  let ascent: Double
  
  private enum CodingKeys: String, CodingKey {
    case name = "fName"
    case familyName = "fFamily"
    case style = "fStyle"
    case ascent = "ascent"
  }
  
  init(dictionary: [String : Any]) throws {
    self.name = try dictionary.valueFor(key: CodingKeys.name.rawValue)
    self.familyName = try dictionary.valueFor(key: CodingKeys.familyName.rawValue)
    self.style = try dictionary.valueFor(key: CodingKeys.style.rawValue)
    self.ascent = try dictionary.valueFor(key: CodingKeys.ascent.rawValue)
  }
  
}

/// A list of fonts
final class FontList: Codable, DictionaryInitializable {
  
  let fonts: [Font]
  
  enum CodingKeys : String, CodingKey {
    case fonts = "list"
  }

  init(dictionary: [String : Any]) throws {
    let fontDictionaries: [[String: Any]] = try dictionary.valueFor(key: CodingKeys.fonts.rawValue)
    self.fonts = try fontDictionaries.map({ try Font(dictionary:$0) })
  }
  
}
