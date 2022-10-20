//
// DotLottieSettings.swift
// Lottie
//
// Created by Evandro Hoffmann on 19/10/22.
//

import Foundation

struct DotLottieConfiguration {
  var imageProvider: FilepathImageProvider?
  var loopMode: LottieLoopMode
  var speed: CGFloat
}

//extension LottieAnimationView {
// /// Applies dotLottie configuration to player
// /// - Parameter lottie: DotLottieSettings to apply
// func applySettings(with lottie: DotLottieConfiguration?) {
//   guard let lottie else { return }
//   loopMode = lottie.loopMode
//   animationSpeed = lottie.speed
//
//   if let bundleURL = lottie.file.imageProvider {
//     self.imageProvider = imageProvider
//   }
// }
//}
