//
//  LottieAnimationViewBase.swift
//  lottie-swift-iOS
//
//  Created by Brandon Withrow on 2/6/19.
//

#if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
import UIKit

/// The base view for `LottieAnimationView` on iOS, tvOS, watchOS, and macCatalyst.
///
/// Enables the `LottieAnimationView` implementation to be shared across platforms.
open class LottieAnimationViewBase: UIView {

  // MARK: Public

  public override var contentMode: UIView.ContentMode {
    didSet {
      setNeedsLayout()
    }
  }

  public override func didMoveToWindow() {
    super.didMoveToWindow()
    animationMovedToWindow()
  }

  public override func layoutSubviews() {
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
    // Implemented by subclasses.
  }

  func animationMovedToWindow() {
    // Implemented by subclasses.
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
    // Implemented by subclasses.
  }

  @objc
  func animationWillEnterForeground() {
    // Implemented by subclasses.
  }

}
#endif
