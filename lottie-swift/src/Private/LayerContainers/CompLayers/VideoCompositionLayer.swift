//
//  VideoCompositionLayer.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 11/29/19.
//
//

import Foundation
import CoreGraphics
import QuartzCore
import AVFoundation
#if os(iOS)
import UIKit
#endif

class VideoCompositionLayer: CompositionLayer & CAAnimationDelegate {
    private var playerLayer: AVPlayerLayer?
    private var oldPlayerLayer: AVPlayerLayer?
    private let file: (name: String, extension: String)
    private let loopVideo: Bool
    private var playing: Bool = false
    private var endVideoObserver: Any?
    var videoProvider: AnimationVideoProvider? {
      didSet {
        oldPlayerLayer?.removeFromSuperlayer()
        updatePlayer()
      }
    }
    
    deinit {
        if let endVideoObserver = endVideoObserver {
            NotificationCenter.default.removeObserver(endVideoObserver)
        }
        
        #if os(iOS)
        if let appResumeObserver = appResumeObserver {
            NotificationCenter.default.removeObserver(appResumeObserver)
        }
        #endif
    }
    
    init(videoModel: VideoLayerModel, videoProvider: AnimationVideoProvider = DefaultVideoProvider()) {
        file = (name: videoModel.fileName ?? "", extension: videoModel.fileExtension ?? "")
        self.videoProvider = videoProvider
        loopVideo = videoModel.loopVideo
        
        super.init(layer: videoModel, size: .zero)
        
        updatePlayer()
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
    
    private func updatePlayer() {
        guard let url = self.videoProvider?.urlFor(keypathName: self.keypathName, file: self.file) else { return }
        
        let assetLoader: (URL) -> (AVPlayer?, CGSize?) = { url in
            let asset = AVAsset(url: url)
            guard let contentSize = self.resolutionForLocalVideo(asset: asset) else { return (nil, nil) }
            
            let playerItem = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: playerItem)
            if #available(OSX 10.14, iOS 12, tvOS 12.0, *) {
                player.preventsDisplaySleepDuringVideoPlayback = false
            }
            return (player, contentSize)
        }
        
        #if os(macOS)
        let videoProvider = self.videoProvider
        let backgroundQueue = DispatchQueue.global()
        backgroundQueue.async {
            let (player, size) = assetLoader(url)
            guard let unwrappedPlayer = player, let unwrappedSize = size else { return }
            DispatchQueue.main.async {
                guard self.videoProvider === videoProvider else { return }

                self.configure(with: unwrappedPlayer, contentSize: unwrappedSize)
            }
        }
        #else
        let (player, size) = assetLoader(url)
        guard let unwrappedPlayer = player, let unwrappedSize = size else { return }
        configure(with: unwrappedPlayer, contentSize: unwrappedSize)
        #endif
    }
    
    private func configure(with player: AVPlayer, contentSize: CGSize) {
        if let endVideoObserver = self.endVideoObserver {
            NotificationCenter.default.removeObserver(endVideoObserver)
        }
        
        let playerLayer = AVPlayerLayer()
        playerLayer.player = player
        playerLayer.frame = CGRect(origin: .zero, size: contentSize)
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
        #elseif os(iOS)
        playerLayer.videoGravity = .resizeAspectFill
        setupAppResumeHandler(for: player)
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
        
        contentsLayer.addSublayer(playerLayer)
        self.playerLayer = playerLayer
    }
    
    private func configure(fadeAnimation: CAAnimation, for layer: CALayer) {
        fadeAnimation.duration = 1.0
        fadeAnimation.fillMode = .forwards
        fadeAnimation.isRemovedOnCompletion = false
        
        layer.add(fadeAnimation, forKey: #keyPath(CALayer.opacity))
    }
    
    private func resolutionForLocalVideo(asset: AVAsset) -> CGSize? {
        guard let track = asset.tracks(withMediaType: .video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        oldPlayerLayer?.opacity = 0.0
        oldPlayerLayer?.removeFromSuperlayer()
        oldPlayerLayer = nil
        
        playerLayer?.opacity = 1.0
    }
    
    #if os(iOS)
    // Method below is required to fix an issue when video freezes on app resume
    private var appResumeObserver: Any?
    private func setupAppResumeHandler(for player: AVPlayer) {
        if let observer = appResumeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        appResumeObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                                   object: UIApplication.shared,
                                                                  queue: .main) { [weak self] _ in
            if self?.playing == true {
                player.play()
            }
        }
    }
    #endif
}
