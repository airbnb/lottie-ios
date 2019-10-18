//
//  VideoCompositionLayer.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 10/16/19.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import Foundation
import CoreGraphics
import QuartzCore
import AVFoundation

class VideoCompositionLayer: CompositionLayer {
    let playerLayer = AVPlayerLayer()
    
    init(videoModel: VideoLayerModel) {
        super.init(layer: videoModel, size: .zero)

        guard let contentUrl = Bundle.main.url(forResource: videoModel.fileName, withExtension: videoModel.fileExtension),
              let contentSize = resolutionForLocalVideo(url: contentUrl) else { return }
        let player = AVPlayer(url: contentUrl)
        playerLayer.player = player
        playerLayer.frame = CGRect(origin: .zero, size: contentSize)
        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        contentsLayer.addSublayer(playerLayer)
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
        if playerLayer.player?.rate ?? 0.0 < 1.0 {
            playerLayer.player?.play()
        }
        super.displayContentsWithFrame(frame: frame, forceUpdates: forceUpdates)
    }
    
    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: .video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}
