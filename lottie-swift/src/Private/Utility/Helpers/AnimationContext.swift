//
//  AnimationContext.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/1/19.
//

import CoreGraphics
import Foundation
import QuartzCore

/// A completion block for animations. `true` is passed in if the animation completed playing.
public typealias LottieCompletionBlock = (Bool) -> Void

// MARK: - AnimationContext

struct AnimationContext {

  init(
    playFrom: CGFloat,
    playTo: CGFloat,
    closure: LottieCompletionBlock?)
  {
    self.playTo = playTo
    self.playFrom = playFrom
    self.closure = AnimationCompletionDelegate(completionBlock: closure)
  }

  var playFrom: CGFloat
  var playTo: CGFloat
  var closure: AnimationCompletionDelegate

}

// MARK: - AnimationContextState

enum AnimationContextState {
  case playing
  case cancelled
  case complete
}

// MARK: - AnimationCompletionDelegate

class AnimationCompletionDelegate: NSObject, CAAnimationDelegate {

  // MARK: Lifecycle

  init(completionBlock: LottieCompletionBlock?) {
    self.completionBlock = completionBlock
    super.init()
  }

  // MARK: Public

  public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard ignoreDelegate == false else { return }
    animationState = flag ? .complete : .cancelled
    if let animationLayer = animationLayer, let key = animationKey {
      animationLayer.removeAnimation(forKey: key)
      if flag {
        animationLayer.currentFrame = (anim as! CABasicAnimation).toValue as! CGFloat
      }
    }
    if let completionBlock = completionBlock {
      completionBlock(flag)
    }
  }

  // MARK: Internal

  var animationLayer: AnimationContainer?
  var animationKey: String?
  var ignoreDelegate: Bool = false
  var animationState: AnimationContextState = .playing

  let completionBlock: LottieCompletionBlock?
}
