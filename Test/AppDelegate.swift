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
class AppDelegate: NSObject, NSApplicationDelegate {
    @objc dynamic var currentProgress: CGFloat {
        set {
            animationView?.currentProgress = CGFloat(newValue) / 100.0
            animationView?.play()
        }
        
        get {
            return (animationView?.currentProgress ?? 0.0) * 100.0
        }
    }
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var view: NSView!
    @IBOutlet weak var gendalfView: NSView!
    var animationView: AnimationView?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let animationView = AnimationView(name: "mobilePromo")
        animationView.frame = view.bounds
        animationView.play()
        view.addSubview(animationView)
        animationView.animationSpeed = 0.1
        
        self.animationView = animationView
    }
}
