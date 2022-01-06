//
//  LottieView.swift
//  lottie-swift-iOS
//
//  Created by Brandon Withrow on 2/6/19.
//

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
import UIKit

//public typealias LottieView = UIView

open class LottieView: UIView {

  // MARK: Open

  open override var contentMode: UIView.ContentMode {
    didSet {
      setNeedsLayout()
    }
  }

  open override func didMoveToWindow() {
    super.didMoveToWindow()
    animationMovedToWindow()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    layoutAnimation()
  }

  // MARK: Internal

  var viewLayer: CALayer? {
    layer
  }

  var screenScale: CGFloat {
    UIScreen.main.scale
  }

  func layoutAnimation() {

  }

  func animationMovedToWindow() {

  }

  func commonInit() {
    contentMode = .scaleAspectFit
    clipsToBounds = true
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(animationWillEnterForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(animationWillMoveToBackground),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil)
  }

  @objc
  func animationWillMoveToBackground() {
  }

  @objc
  func animationWillEnterForeground() {
  }

}
#endif
