//
//  LRUAnimationCache.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/5/19.
//

import Foundation

/**
 An Animation Cache that will store animations up to `cacheSize`.
 
 Once `cacheSize` is reached, the least recently used animation will be ejected.
 The default size of the cache is 100.
 */
public class LRUAnimationCache: AnimationCacheProvider {

    public static let sharedCache = LRUAnimationCache()

    public var cacheSize: Int = 100 {
      didSet {
        cache.countLimit = cacheSize
      }
    }

    private var cache = NSCache<NSString, Animation>()

    /// This prevents other objects from using the default initializer
    private init() {
        cache.countLimit = cacheSize
    }

    public func animation(forKey key: String) -> Animation? {
        cache.object(forKey: key.nsString)
    }

    public func setAnimation(_ animation: Animation, forKey key: String) {
        cache.setObject(animation, forKey: key.nsString)
    }

    public func clearCache() {
        // Let ARC manage clearing the cache.
        self.cache = NSCache<NSString, Animation>()
    }
}
