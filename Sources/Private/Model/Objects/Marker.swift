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
    name = try dictionary.value(for: CodingKeys.name)
    frameTime = try dictionary.value(for: CodingKeys.frameTime)
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
