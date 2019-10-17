//
//  AppDelegate.swift
//  Test
//
//  Created by Viktor Radulov on 10/16/19.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import Cocoa
import Lottie
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AnimationImageProvider {
    func imageForAsset(asset: ImageAsset) -> CGImage?
    {
        return nil
    }
    
    @objc dynamic var currentProgress: CGFloat {
        set {
            aview?.currentProgress = CGFloat(newValue) / 100.0
            aview?.play()
        }
        
        get {
            return (aview?.currentProgress ?? 0.0) * 100.0
        }
    }
    

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var view: NSView!
    @IBOutlet weak var gendalfView: NSView!
    var aview: AnimationView?
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        do {
        aview = AnimationView(name: "lumis")
        aview?.frame = view.bounds
        
        aview?.imageProvider = self
        aview?.play()
        
        view.addSubview(aview!)
        } catch let e {
            
        }
        
//        let playerLayer = AVPlayerLayer()
//        playerLayer.frame = gendalfView.bounds
//        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
//        guard let contentUrl = Bundle.main.url(forResource: "Gandalf", withExtension: "mp4") else { return }
//        let player = AVPlayer(url: contentUrl)
//        playerLayer.player = player
//        gendalfView.layer?.addSublayer(playerLayer)
        
//        player.play()
        
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

