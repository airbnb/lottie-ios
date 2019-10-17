//
//  VideoLayerModel.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 10/16/19.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import Foundation

class VideoLayerModel: LayerModel {
  
  var fileName: String?
  var fileExtension: String?
  
  required init(from decoder: Decoder) throws {
    try super.init(from: decoder)
    
    let name = self.name.components(separatedBy: ".")
    guard let fileName = name.first, let fileExtension = name.last else {
        throw NSError(domain: "com.lottie.VideoLayerModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Video layer should be name same as video resource"])
    }
    self.fileName = fileName
    self.fileExtension = fileExtension
  }
  
}
