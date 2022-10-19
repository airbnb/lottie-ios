//
// DotLottieSettings.swift
// Lottie
//
// Created by Evandro Hoffmann on 19/10/22.
//

import Foundation

struct DotLottieConfiguration {
  var file: DotLottieFile
  var animation: DotLottieAnimation
  
  var bounce: Bool {
    animation.mode == "bounce"
  }
  
  var loopMode: LottieLoopMode {
    bounce ? .autoReverse : (animation.loop ? .loop : .playOnce)
  }

  var speed: CGFloat {
    CGFloat(animation.speed)*CGFloat(animation.direction ?? 1)
  }
}

extension LottieAnimationView {
 /// Applies dotLottie configuration to player
 /// - Parameter lottie: DotLottieSettings to apply
 func applySettings(with lottie: DotLottieConfiguration?) {
   guard let lottie else { return }
   loopMode = lottie.loopMode
   animationSpeed = lottie.speed

   if let imageProvider = lottie.file.imageProvider {
     self.imageProvider = imageProvider
   }
 }
}
