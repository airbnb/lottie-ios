//
//  LottieView.swift
//  lottie-swift-iOS
//
//  Created by Brandon Withrow on 2/6/19.
//

import Foundation
#if os(OSX)
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

public class LottieView: NSView {
  
  var screenScale: CGFloat {
    return NSApp.mainWindow?.backingScaleFactor ?? 1
  }
  
  var viewLayer: CALayer? {
    return layer
  }
  
  func layoutAnimation() {
    
  }
  
  func animationMovedToWindow() {
    
  }
  
  public override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    animationMovedToWindow()
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
