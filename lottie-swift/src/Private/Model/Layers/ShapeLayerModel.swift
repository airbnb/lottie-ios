//
//  ShapeLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/8/19.
//

import Foundation

/// A layer that holds vector shape objects.
class ShapeLayerModel: LayerModel {
  
  /// A list of shape items.
  private(set) var items: [ShapeItem]
  
  private enum CodingKeys : String, CodingKey {
    case items = "shapes"
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ShapeLayerModel.CodingKeys.self)
    self.items = try container.decode([ShapeItem].self, ofFamily: ShapeType.self, forKey: .items)
    try super.init(from: decoder)
  }
  
  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.items, forKey: .items)
  }
  
}

extension ShapeLayerModel: ContentsReplaceable {
  func replaceContents(with object: ContentsReplaceable) {
    guard let replacementLayer = object as? ShapeLayerModel else { return }
    self.items = Array(replacementLayer.items)
  }
}
