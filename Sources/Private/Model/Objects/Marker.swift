//
//  Marker.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

import Foundation

/// A time marker
final class Marker: Codable, DictionaryInitializable {

  // MARK: Lifecycle

  init(dictionary: [String: Any]) throws {
    name = try dictionary.valueFor(key: CodingKeys.name.rawValue)
    frameTime = try dictionary.valueFor(key: CodingKeys.frameTime.rawValue)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case name = "cm"
    case frameTime = "tm"
  }

  /// The Marker Name
  let name: String

  /// The Frame time of the marker
  let frameTime: AnimationFrameTime

}
