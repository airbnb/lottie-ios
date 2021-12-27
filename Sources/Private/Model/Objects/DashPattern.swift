//
//  DashPattern.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/22/19.
//

import Foundation

// MARK: - DashElementType

enum DashElementType: String, Codable {
  case offset = "o"
  case dash = "d"
  case gap = "g"
}

// MARK: - DashElement

final class DashElement: Codable {

  enum CodingKeys: String, CodingKey {
    case type = "n"
    case value = "v"
  }

  let type: DashElementType
  let value: KeyframeGroup<Vector1D>
}
