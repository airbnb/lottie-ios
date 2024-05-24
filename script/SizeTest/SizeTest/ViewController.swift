//
//  ViewController.swift
//  SizeTest
//
//  Created by Noah Martin on 8/5/23.
//

import Lottie
import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let starAnimationView = LottieAnimationView(name: "9squares_AlBoardman")
    view.addSubview(starAnimationView)
    starAnimationView.translatesAutoresizingMaskIntoConstraints = false
    starAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    starAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    starAnimationView.play()
  }

}
