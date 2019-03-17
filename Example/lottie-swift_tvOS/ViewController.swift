//
//  ViewController.swift
//  lottie-swift_tvOS
//
//  Created by Brandon Withrow on 2/5/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Lottie

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let animation = Animation.named("LottieLogo1", subdirectory: "TestAnimations")
    let animationView = AnimationView(animation: animation)
    view.addSubview(animationView)
    animationView.contentMode = .scaleAspectFill
    animationView.loopMode = .loop
    animationView.play()
    
    animationView.translatesAutoresizingMaskIntoConstraints = false
    animationView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
    animationView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
    animationView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    animationView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
    // Do any additional setup after loading the view, typically from a nib.
  }


}

