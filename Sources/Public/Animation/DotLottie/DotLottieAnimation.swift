//
// DotLottieAnimation.swift
// Pods
//
// Created by Evandro Harrison Hoffmann on 28/06/2021.
//

import Foundation

public struct DotLottieAnimation: Codable {
  /// Id of Animation
  var id: String
  
  /// Loop enabled
  var loop: Bool
  
  // appearance color in HEX
  var themeColor: String
  
  /// Animation Playback Speed
  var speed: Float
  
  /// 1 or -1
  var direction: Int? = 1
  
  /// mode - "bounce" | "normal"
  var mode: String? = "normal"
    
    /// URL to animation, to be set internally
    public var animationUrl: URL?
    
    /// Loads `LottieAnimation` from `animationUrl`
    /// - Returns: Deserialized `LottieAnimation`. Optional.
    public func animation() throws -> LottieAnimation {
        guard let animationUrl else {
            throw DotLottieError.animationNotAvailable
        }
        let data = try Data(contentsOf: animationUrl)
        return try LottieAnimation.from(data: data)
    }
   
    /// Loop mode for animation
    public var loopMode: LottieLoopMode {
        mode == "bounce" ? .autoReverse : (loop ? .loop : .playOnce)
    }
    
    /// Animation speed
    public var animationSpeed: CGFloat {
      CGFloat(speed)*CGFloat(direction ?? 1)
    }
}
