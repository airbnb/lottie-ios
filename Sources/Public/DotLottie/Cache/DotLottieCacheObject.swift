//
//  DotLottieCacheObject.swift
//  Lottie
//
//  Created by hyosung on 1/21/24.
//

import Foundation

final class DotLottieCacheObject: NSObject, NSDiscardableContent {
  internal var lottie: DotLottieFile?

  internal func beginContentAccess() -> Bool {
    return true
  }
  
  internal func endContentAccess() { }
  
  internal func discardContentIfPossible() {
    lottie = nil
  }
  
  internal func isContentDiscarded() -> Bool {
    return lottie == nil
  }
}
