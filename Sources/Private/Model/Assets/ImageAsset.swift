//
//  ImageAsset.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

import Foundation

public final class ImageAsset: Asset {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ImageAsset.CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    directory = try container.decode(String.self, forKey: .directory)
    width = try container.decode(Double.self, forKey: .width)
    height = try container.decode(Double.self, forKey: .height)
    try super.init(from: decoder)
  }

  // MARK: Public

  /// Image name
  public let name: String

  /// Image Directory
  public let directory: String

  /// Image Size
  public let width: Double

  public let height: Double

  override public func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(directory, forKey: .directory)
    try container.encode(width, forKey: .width)
    try container.encode(height, forKey: .height)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case name = "p"
    case directory = "u"
    case width = "w"
    case height = "h"
  }
}
