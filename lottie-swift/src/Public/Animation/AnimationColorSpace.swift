//
//  AnimationColorSpace.swift
//  lottie-swift
//
//  Created by Kyle Fox on 5/14/21.
//

@available(iOS 10, *)
public final class AnimationColorSpace {

    public init() { }

    public static let shared = AnimationColorSpace()

    /// Set this variable to choose whether to use p3 Color Space in all animations.
    public var useP3ColorSpace: Bool = false

}
