//
//  AnimationFromAssetLoading.swift
//  Lottie
//
//  Created by Fouquet, René on 22.07.19.
//

import Foundation
import UIKit

public extension AnimationView {
    /**
     Loads a Lottie animation from a JSON file located in the Asset catalog of the supplied bundle.

     - Parameter name: The string name of the lottie animation in the asset catalog.
     - Parameter bundle: The bundle in which the animation is located.
     Defaults to the Main bundle.
     - Parameter imageProvider: An image provider for the animation's image data.
     If none is supplied Lottie will search in the supplied bundle for images.
     */
    convenience init(asset name: String,
                     bundle: Bundle = Bundle.main,
                     imageProvider: AnimationImageProvider? = nil,
                     animationCache: AnimationCacheProvider? = LRUAnimationCache.sharedCache) {
        let animation = Animation.asset(name, bundle: bundle, animationCache: animationCache)
        let provider = imageProvider ?? BundleImageProvider(bundle: bundle, searchPath: nil)
        self.init(animation: animation, imageProvider: provider)
    }
}

public extension Animation {
    /**
     Loads an animation model from the asset catalog by its name. Returns `nil` if an animation is not found.

     - Parameter name: The name of the json file in the asset catalog. EG "StarAnimation"
     - Parameter bundle: The bundle in which the animation is located. Defaults to `Bundle.main`
     - Parameter animationCache: A cache for holding loaded animations. Optional.

     - Returns: Deserialized `Animation`. Optional.
     */
    static func asset(_ name: String,
                      bundle: Bundle = Bundle.main,
                      animationCache: AnimationCacheProvider? = nil) -> Animation? {
        /// Create a cache key for the animation.
        let cacheKey = bundle.bundlePath + "/" + name

        /// Check cache for animation
        if let animationCache = animationCache,
            let animation = animationCache.animation(forKey: cacheKey) {
            /// If found, return the animation.
            return animation
        }

        /// Load jsonData from Asset
        guard let json = NSDataAsset.init(name: name, bundle: bundle)?.data else {
            return nil
        }
        do {
            /// Decode animation.
            let animation = try JSONDecoder().decode(Animation.self, from: json)
            animationCache?.setAnimation(animation, forKey: cacheKey)
            return animation
        } catch {
            /// Decoding error.
            return nil
        }
    }
}
