//
//  DefaultAnimationCache.swift
//  Lottie
//
//  Created by Marcelo Fabri on 10/18/22.
//

import Foundation

// MARK: - DefaultAnimationCache

/// A thread-safe Animation Cache that will store animations up to `cacheSize`.
///
/// Once `cacheSize` is reached, animations can be ejected.
/// The default size of the cache is 100.
///
/// This cache implementation also responds to memory pressure.
public class DefaultAnimationCache: AnimationCacheProvider {

  // MARK: Lifecycle

  public init() {
    cache.countLimit = Self.defaultCacheCountLimit
  }

  // MARK: Public

  /// The global shared Cache.
  public static let sharedCache = DefaultAnimationCache()

  /// The maximum number of animations that can be stored in the cache.
  public var cacheSize: Int {
    get { cache.countLimit }
    set { cache.countLimit = newValue }
  }

  /// Clears the Cache.
  public func clearCache() {
    cache.removeAllObjects()
  }

  public func animation(forKey key: String) -> LottieAnimation? {
    let object = cache.object(forKey: key as NSString)
    return object?.animation
  }

  public func setAnimation(_ animation: LottieAnimation, forKey key: String) {
    let lottieAnimationCache = LottieAnimationCacheObject()
    lottieAnimationCache.animation = animation
    cache.setObject(lottieAnimationCache, forKey: key as NSString)
  }

  // MARK: Private

  private static let defaultCacheCountLimit = 100
  private let cache = NSCache<NSString, LottieAnimationCacheObject>()
}

// MARK: Sendable

// LottieAnimationCache has a Sendable requirement, but we can't
// redesign DefaultAnimationCache to be properly Sendable without
// making breaking changes.
// swiftlint:disable:next no_unchecked_sendable
extension DefaultAnimationCache: @unchecked Sendable { }
