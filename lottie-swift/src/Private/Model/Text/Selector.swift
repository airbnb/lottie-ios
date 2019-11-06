//
//  Selector.swift
//  
//
//  Created by Viktor Radulov on 11/6/19.
//

import Foundation

class Selector: Codable {
    
    enum BasedOn: Int {
        case characters = 1
        case charactersExludingSpace = 2
        case words = 3
        case lines = 4
    }
  
  let type: Int
  let basedOn: BasedOn
  
  private enum CodingKeys: String, CodingKey {
    case type = "t"
    case basedOn = "b"
    case expression = "x"
  }
    
    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.basedOn = BasedOn(rawValue: try container.decode(Int.self, forKey: .basedOn)) ?? .words
      self.type = try container.decode(Int.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      try container.encode(type, forKey: .type)
      try container.encode(basedOn.rawValue, forKey: .basedOn)
    }
}
