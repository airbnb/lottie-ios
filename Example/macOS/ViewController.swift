//
//  ViewController.swift
//  lottie-swift_macOS
//
//  Created by Brandon Withrow on 2/5/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Cocoa
import Lottie

class ViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let animation = Animation.named("Samples/LottieLogo1")
    let animationView = AnimationView(animation: animation)
    view.addSubview(animationView)
    preferredContentSize = animationView.bounds.size
    animationView.loopMode = .loop
    animationView.play()
  }

}
