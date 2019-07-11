//
//  Font.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

import Foundation

public class Font: Codable {
  
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
  
}

/// A list of fonts
public class FontList: Codable {
  
  public let fonts: [Font]
  
  enum CodingKeys : String, CodingKey {
    case fonts = "list"
  }
  
}
