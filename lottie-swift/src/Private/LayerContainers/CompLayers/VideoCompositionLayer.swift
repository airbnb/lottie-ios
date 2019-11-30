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
    let file: (name: String, extension: String)
    let loopVideo: Bool
    var playing: Bool = false
    var endVideoObserver: Any?
    var videoProvider: AnimationVideoProvider? {
      didSet {
        updatePlayer()
        if playing {
            playerLayer.player?.play()
        }
      }
    }
    
    deinit {
        if let endVideoObserver = endVideoObserver {
            NotificationCenter.default.removeObserver(endVideoObserver)
        }
    }
    
    init(videoModel: VideoLayerModel, videoProvider: AnimationVideoProvider = DefaultVideoProvider()) {
        file = (name: videoModel.fileName ?? "", extension: videoModel.fileExtension ?? "")
        self.videoProvider = videoProvider
        loopVideo = videoModel.loopVideo
        
        super.init(layer: videoModel, size: .zero)
        
        updatePlayer()
        contentsLayer.addSublayer(playerLayer)
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
        playerLayer.player?.play()
        playing = true
        super.displayContentsWithFrame(frame: frame, forceUpdates: forceUpdates)
    }
    
    private func updatePlayer() {
        if let url = videoProvider?.urlFor(keypathName: keypathName, file: file),
           let contentSize = resolutionForLocalVideo(url: url) {
            let player = AVPlayer(url: url)
            if #available(OSX 10.14, iOS 12, *) {
                player.preventsDisplaySleepDuringVideoPlayback = false
            }
            playerLayer.player = player
            playerLayer.frame = CGRect(origin: .zero, size: contentSize)
            endVideoObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                                      object: player.currentItem,
                                                                      queue: .main) { [weak self] _ in
                if self?.loopVideo == true {
                    player.seek(to: CMTime.zero)
                    player.play()
                } else {
                    self?.playing = false
                }
            }
            #if os(macOS)
            playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            #else
            playerLayer.videoGravity = .resizeAspectFill
            #endif
        }
    }
    
    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: .video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}
