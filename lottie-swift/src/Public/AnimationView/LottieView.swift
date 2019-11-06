//
//  LottieView.swift
//  lottie-swift-iOS
//
//  Created by Brandon Withrow on 2/6/19.
//

import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)

import UIKit

//public typealias LottieView = UIView

open class LottieView: UIView {

  var viewLayer: CALayer? {
    return layer
  }

  func layoutAnimation() {

  }
  
  func animationMovedToWindow() {
    
  }
  
  open override func didMoveToWindow() {
    super.didMoveToWindow()
    animationMovedToWindow()
  }
  
  var screenScale: CGFloat {
    return UIScreen.main.scale
  }

  func commonInit() {
    contentMode = .scaleAspectFit
    clipsToBounds = true
    NotificationCenter.default.addObserver(self, selector: #selector(animationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(animationWillMoveToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
  }

  open override var contentMode: UIView.ContentMode {
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

#else

import AppKit

public enum LottieContentMode: Int {
  case scaleToFill
  case scaleAspectFit
  case scaleAspectFill
  case redraw
  case center
  case top
  case bottom
  case left
  case right
  case topLeft
  case topRight
  case bottomLeft
  case bottomRight
}

/// A wrapper around NSView for cross platform compatibility.
@objcMembers
public class LottieView: NSView {
  
  var screenScale: CGFloat {
    return NSApp.mainWindow?.backingScaleFactor ?? 2.0
  }
  
  var viewLayer: CALayer? {
    return layer
  }
  
  func layoutAnimation() {
    
  }
  
  func animationMovedToWindow() {
    
  }
    @objc
    func renderScaleDidChange(_ notification: NSNotification? = nil) {
        
    }
  
  public override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    animationMovedToWindow()
    NotificationCenter.default.addObserver(self, selector: #selector(renderScaleDidChange(_:)), name: NSWindow.didChangeScreenNotification, object: window)
  }
  
  func commonInit() {
    self.wantsLayer = true
  }
  
  func setNeedsLayout() {
    self.needsLayout = true
  }
  
  func layoutIfNeeded() {
    
  }
  
  public override var wantsUpdateLayer: Bool {
    return true
  }
  
  public override var isFlipped: Bool {
    return true
  }
  
  public var contentMode: LottieContentMode = .scaleAspectFit {
    didSet {
      setNeedsLayout()
    }
  }
  
  public override func layout() {
    super.layout()
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    self.layoutAnimation()
    CATransaction.commit()
  }
  
  @objc func animationWillMoveToBackground() {
  }
  
  @objc func animationWillEnterForeground() {
  }
  
}

#endif
