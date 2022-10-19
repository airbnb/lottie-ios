//
//  DotLottieAnimation.swift
//  Pods
//
//  Created by Evandro Harrison Hoffmann on 28/06/2021.
//

import Foundation

public struct DotLottieAnimation: Codable {
    /// Id of Animation
    public var id: String
    
    /// Loop enabled
    public var loop: Bool
    
    // appearance color in HEX
    public var themeColor: String
    
    /// Animation Playback Speed
    public var speed: Float
    
    /// 1 or -1
    public var direction: Int = 1
    
    /// mode - "bounce" | "normal"
    public var mode: String = "normal"
    
    public init(id: String, loop: Bool, themeColor: String, speed: Float, direction: Int = 1, mode: String = "normal") {
        self.id = id
        self.loop = loop
        self.themeColor = themeColor
        self.speed = speed
        self.direction = direction
        self.mode = mode
    }
}
