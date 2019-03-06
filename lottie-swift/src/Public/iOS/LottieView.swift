//
//  LottieView.swift
//  lottie-swift-iOS
//
//  Created by Brandon Withrow on 2/6/19.
//

import Foundation
import UIKit

//public typealias LottieView = UIView

open class LottieView: UIView {

  var viewLayer: CALayer? {
    return layer
  }

  func layoutAnimation() {

  }
  
  var screenScale: CGFloat {
    return UIScreen.main.scale
  }

  func commonInit() {
    contentMode = .scaleAspectFit
    clipsToBounds = true
    NotificationCenter.default.addObserver(self, selector: #selector(animationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(animationWillMoveToBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
  }

  open override var contentMode: UIViewContentMode {
    didSet {
      setNeedsLayout()
    }
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    self.layoutAnimation()
  }
  
  @objc func animationWillMoveToBackground() {
  }
  
  @objc func animationWillEnterForeground() {
  }
  
}
