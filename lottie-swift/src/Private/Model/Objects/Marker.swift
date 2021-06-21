//
//  Marker.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

import Foundation

/// A time marker
final class Marker: Codable, DictionaryInitializable {
  
  /// The Marker Name
  let name: String
  
  /// The Frame time of the marker
  let frameTime: AnimationFrameTime
  
  enum CodingKeys : String, CodingKey {
    case name = "cm"
    case frameTime = "tm"
  }

  init(dictionary: [String : Any]) throws {
    self.name = try dictionary.valueFor(key: CodingKeys.name.rawValue)
    self.frameTime = try dictionary.valueFor(key: CodingKeys.frameTime.rawValue)
  }
}
