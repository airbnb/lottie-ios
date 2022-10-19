//
//  DefaultAnimationCache.swift
//  Lottie
//
//  Created by Marcelo Fabri on 10/18/22.
//

import Foundation

/// A thread-safe Animation Cache that will store animations up to `cacheSize`.
///
/// Once `cacheSize` is reached, animations can be ejected.
/// The default size of the cache is 100.
///
/// This cache implementation also responds to memory pressure, as it's backed by `NSCache`.
public class DefaultAnimationCache: AnimationCacheProvider {

  // MARK: Lifecycle

  public init() {
    cache.countLimit = Self.defaultCacheCountLimit
  }

  // MARK: Public

  /// The global shared Cache.
  public static let sharedCache = DefaultAnimationCache()

  /// The size of the cache.
  public var cacheSize = defaultCacheCountLimit {
    didSet {
      cache.countLimit = cacheSize
    }
  }

  /// Clears the Cache.
  public func clearCache() {
    cache.removeAllObjects()
  }

  public func animation(forKey key: String) -> LottieAnimation? {
    cache.object(forKey: key as NSString)
  }

  public func setAnimation(_ animation: LottieAnimation, forKey key: String) {
    cache.setObject(animation, forKey: key as NSString)
  }

  // MARK: Private

  private static let defaultCacheCountLimit = 100

  private var cache = NSCache<NSString, LottieAnimation>()
}
