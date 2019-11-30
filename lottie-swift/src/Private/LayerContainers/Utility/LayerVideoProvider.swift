//
//  LayerVideoProvider.swift
//  lottie-ios-iOS
//
//  Created by Viktor Radulov on 11/30/19.
//

import Foundation

class LayerVideoProvider {
    
    var videoProvider: AnimationVideoProvider {
        didSet {
            reloadVideo()
        }
    }
    
    fileprivate(set) var layers: [VideoCompositionLayer]
    
    init(videoProvider: AnimationVideoProvider) {
        self.videoProvider = videoProvider
        self.layers = []
        reloadVideo()
    }

    func addLayers(_ layers: [VideoCompositionLayer]) {
        self.layers += layers
    }
        
    func reloadVideo() {
        layers.forEach {
            $0.videoProvider = videoProvider
        }
    }
}
