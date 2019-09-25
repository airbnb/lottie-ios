//
//  AssetLibrary.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

import Foundation

class AssetLibrary: Codable {
  
  /// The Assets
  private(set) var  assets: [String : Asset]
  
  private(set) var  imageAssets: [String : ImageAsset]
  private(set) var precompAssets: [String : PrecompAsset]
  
  required init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    var containerForKeys = container
    
    var decodedAssets = [String : Asset]()
    
    var imageAssets = [String : ImageAsset]()
    var precompAssets = [String : PrecompAsset]()
    
    while !container.isAtEnd {
      let keyContainer = try containerForKeys.nestedContainer(keyedBy: PrecompAsset.CodingKeys.self)
      if keyContainer.contains(.layers) {
        let precompAsset = try container.decode(PrecompAsset.self)
        decodedAssets[precompAsset.id] = precompAsset
        precompAssets[precompAsset.id] = precompAsset
      } else {
        let imageAsset = try container.decode(ImageAsset.self)
        decodedAssets[imageAsset.id] = imageAsset
        imageAssets[imageAsset.id] = imageAsset
      }
    }
    self.assets = decodedAssets
    self.precompAssets = precompAssets
    self.imageAssets = imageAssets
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(contentsOf: Array(assets.values))
  }
}

extension AssetLibrary: ContentsReplaceable {
  func replaceContents(with object: ContentsReplaceable) {
    guard let replacementLibrary = object as? AssetLibrary else { return }
    for assetKey in self.precompAssets.keys {
      if let replacement = replacementLibrary.precompAssets[assetKey] {
        self.precompAssets[assetKey] = replacement
        self.assets[assetKey] = replacement
      }
    }
    for assetKey in self.imageAssets.keys {
      if let replacement = replacementLibrary.imageAssets[assetKey] {
        self.imageAssets[assetKey] = replacement
        self.assets[assetKey] = replacement
      }
    }
  }
}
