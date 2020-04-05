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

class VideoCompositionLayer: CompositionLayer & CAAnimationDelegate {
    private var playerLayer: AVPlayerLayer?
    private var oldPlayerLayer: AVPlayerLayer?
    private let file: (name: String, extension: String)
    private let loopVideo: Bool
    private var playing: Bool = false
    private var endVideoObserver: Any?
    var videoProvider: AnimationVideoProvider? {
      didSet {
        startUpdatingPlayer()
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
        
        startUpdatingPlayer()
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
        if !playing {
            playing = true
            playerLayer?.player?.play()
        }
        
        super.displayContentsWithFrame(frame: frame, forceUpdates: forceUpdates)
    }
    
    override func hideContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
        if playing {
            playerLayer?.player?.pause()
            playing = false
        }
        
        super.hideContentsWithFrame(frame: frame, forceUpdates: forceUpdates)
    }
    
    private func startUpdatingPlayer() {
        if #available(macOS 10.13, *) {
            if #available(macOS 10.14, *) {
                DispatchQueue.global(priority: .default).async {
                    self.updatePlayer()
                }
            } else {
                self.updatePlayer()
            }
        } else {
            DispatchQueue.global(priority: .default).async {
                self.updatePlayer()
            }
        }
    }
    
    private func updatePlayer() {
            if let url = self.videoProvider?.urlFor(keypathName: self.keypathName, file: self.file),
                let contentSize = self.resolutionForLocalVideo(url: url) {
                let playerLayer = AVPlayerLayer()
                let player = AVPlayer(url: url)
                if #available(OSX 10.14, iOS 12, *) {
                    player.preventsDisplaySleepDuringVideoPlayback = false
                }
                playerLayer.player = player
                playerLayer.frame = CGRect(origin: .zero, size: contentSize)
                if let endVideoObserver = self.endVideoObserver {
                    NotificationCenter.default.removeObserver(endVideoObserver)
                }
                self.endVideoObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                                          object: player.currentItem,
                                                                          queue: .main) { [weak self] _ in
                    if self?.loopVideo == true, self?.playing == true {
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
                
                if let oldPlayerLayer = self.playerLayer {
                    playerLayer.opacity = 0.0
                    
                    let fadeIn = CABasicAnimation()
                    fadeIn.fromValue = 0.0
                    fadeIn.toValue = 1.0
                    self.configure(fadeAnimation: fadeIn, for: playerLayer)
                    
                    let fadeOut = CABasicAnimation()
                    fadeOut.fromValue = 1.0
                    fadeOut.toValue = 0.0
                    fadeOut.delegate = self
                    self.configure(fadeAnimation: fadeOut, for: oldPlayerLayer)
                    
                    self.oldPlayerLayer = oldPlayerLayer
                }
                if self.playing {
                    player.play()
                }
                DispatchQueue.main.async {
                    self.contentsLayer.addSublayer(playerLayer)
                }
                
                self.playerLayer = playerLayer
            }
    }
    
    private func configure(fadeAnimation: CAAnimation, for layer: CALayer) {
        fadeAnimation.duration = 1.0
        fadeAnimation.fillMode = .forwards
        fadeAnimation.isRemovedOnCompletion = false
        
        layer.add(fadeAnimation, forKey: #keyPath(CALayer.opacity))
    }
    
    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: .video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        oldPlayerLayer?.opacity = 0.0
        oldPlayerLayer?.removeFromSuperlayer()
        oldPlayerLayer = nil
        
        playerLayer?.opacity = 1.0
    }
}
