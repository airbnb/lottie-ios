//
//  Font.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

import Foundation

// MARK: - Font

final class Font: Codable {

  // MARK: Internal

  let name: String
  let familyName: String
  let style: String
  let ascent: Double

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case name = "fName"
    case familyName = "fFamily"
    case style = "fStyle"
    case ascent = "ascent"
  }

}

// MARK: - FontList

/// A list of fonts
final class FontList: Codable {

  enum CodingKeys: String, CodingKey {
    case fonts = "list"
  }

  let fonts: [Font]
}
