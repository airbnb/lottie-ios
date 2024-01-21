//
//  LottieAnimationCacheObject.swift
//  Lottie
//
//  Created by hyosung on 1/21/24.
//

import Foundation

final class LottieAnimationCacheObject: NSObject, NSDiscardableContent {
  internal var animation: LottieAnimation?

  internal func beginContentAccess() -> Bool {
    return true
  }
  
  internal func endContentAccess() { }
  
  internal func discardContentIfPossible() {
    animation = nil
  }
  
  internal func isContentDiscarded() -> Bool {
    return animation == nil
  }
}
