//
//  MockMainThreadAnimationLayer.swift
//  Lottie
//
//  Created by Chuy Cruz on 4/5/23.
//

import Foundation
import QuartzCore

final class MockMainThreadAnimationLayer: CALayer, RootAnimationLayer {
    var currentFrame: AnimationFrameTime
    
    var renderScale: CGFloat
    
    var respectAnimationFrameRate: Bool
    
    var _animationLayers: [CALayer]
    
    var imageProvider: AnimationImageProvider
    
    var textProvider: AnimationTextProvider
    
    var fontProvider: AnimationFontProvider
    
    var primaryAnimationKey: AnimationKey
    
    var isAnimationPlaying: Bool?
    
    func removeAnimations() {
        // no-op
    }
    
    func reloadImages() {
        // no-op
    }
    
    func forceDisplayUpdate() {
        // no-op
    }
    
    func logHierarchyKeypaths() {
        // no-op
    }
    
    func allHierarchyKeypaths() -> [String] {
        // no-op
        return []
    }
    
    func setValueProvider(_ valueProvider: AnyValueProvider, keypath: AnimationKeypath) {
        // no-op
    }
    
    func getValue(for keypath: AnimationKeypath, atFrame: AnimationFrameTime?) -> Any? {
        // no-op
        return nil
    }
    
    func getOriginalValue(for keypath: AnimationKeypath, atFrame: AnimationFrameTime?) -> Any? {
        // no-op
        return nil
    }
    
    func layer(for keypath: AnimationKeypath) -> CALayer? {
        // no-op
        return nil;
    }
    
    func animatorNodes(for keypath: AnimationKeypath) -> [AnimatorNode]? {
        // no-op
        return nil;
    }
    
    init(
      animation: LottieAnimation,
      imageProvider: AnimationImageProvider,
      textProvider: AnimationTextProvider,
      fontProvider: AnimationFontProvider,
      maskAnimationToBounds: Bool,
      logger: LottieLogger)
    {
        self.currentFrame = AnimationProgressTime()
        self.renderScale = 0
        self.respectAnimationFrameRate = false
        self._animationLayers = []
        self.imageProvider = imageProvider
        self.textProvider = textProvider
        self.fontProvider = fontProvider
        self.primaryAnimationKey = .managed
        super.init()
    }
    
    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
}
