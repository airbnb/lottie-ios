//
//  VideoLayerModel.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 11/29/20.
//
//

import Foundation

class VideoLayerModel: LayerModel {
  
    var fileName: String?
    var fileExtension: String?
    var loopVideo = false

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
