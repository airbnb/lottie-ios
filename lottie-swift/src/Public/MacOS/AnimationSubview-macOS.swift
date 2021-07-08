//
//  AnimationSubview.swift
//  lottie-swift-iOS
//
//  Created by Brandon Withrow on 2/5/19.
//

import Foundation
#if os(OSX)
import AppKit

/// A view that can be added to a keypath of an AnimationView
public final class AnimationSubview: NSView {
  
  var viewLayer: CALayer? {
    return layer
  }
  
}
#endif
