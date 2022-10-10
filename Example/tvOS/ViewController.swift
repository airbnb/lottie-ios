//
//  ViewController.swift
//  lottie-swift_tvOS
//
//  Created by Brandon Withrow on 2/5/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Lottie
import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let animation = LottieAnimation.named("Samples/LottieLogo1")
    let animationView = LottieAnimationView(animation: animation)
    view.addSubview(animationView)
    animationView.contentMode = .scaleAspectFill
    animationView.loopMode = .loop
    animationView.play()

    animationView.translatesAutoresizingMaskIntoConstraints = false
    animationView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
    animationView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
    animationView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    animationView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
  }

}
