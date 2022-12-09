//
// DotLottieAnimation.swift
// Pods
//
// Created by Evandro Harrison Hoffmann on 28/06/2021.
//

import Foundation

struct DotLottieAnimation: Codable {
  /// Id of Animation
  var id: String

  /// Loop enabled
  var loop: Bool? = false

  /// Animation Playback Speed
  var speed: Double? = 1

  /// 1 or -1
  var direction: Int? = 1

  /// mode - "bounce" | "normal"
  var mode: String? = "normal"

  /// URL to animation, to be set internally
  var animationUrl: URL?

  /// Loop mode for animation
  var loopMode: LottieLoopMode {
    mode == "bounce" ? .autoReverse : ((loop ?? false) ? .loop : .playOnce)
  }

  /// Animation speed
  var animationSpeed: Double {
    (speed ?? 1) * Double(direction ?? 1)
  }

  /// Loads `LottieAnimation` from `animationUrl`
  /// - Returns: Deserialized `LottieAnimation`. Optional.
  func animation() throws -> LottieAnimation {
    guard let animationUrl = animationUrl else {
      throw DotLottieError.animationNotAvailable
    }
    let data = try Data(contentsOf: animationUrl)
    return try LottieAnimation.from(data: data)
  }

}
