//
//  LRUDotLottieCache.swift
//  Lottie
//
//  Created by Evandro Hoffmann on 20/10/22.
//

import Foundation

// MARK: - DotLottieCache

/// A DotLottie Cache that will store lottie files up to `cacheSize`.
///
/// Once `cacheSize` is reached, the least recently used lottie will be ejected.
/// The default size of the cache is 100.
public class DotLottieCache: DotLottieCacheProvider {

  // MARK: Lifecycle

  public init() {
    cache.countLimit = Self.defaultCacheCountLimit
  }

  // MARK: Public

  /// The global shared Cache.
  public static let sharedCache = DotLottieCache()

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

  public func file(forKey key: String) -> DotLottieFile? {
    let object = cache.object(forKey: key as NSString)
    return object?.lottie
  }

  public func setFile(_ lottie: DotLottieFile, forKey key: String) {
    let dotLottieCache = DotLottieCacheObject()
    dotLottieCache.lottie = lottie
    cache.setObject(dotLottieCache, forKey: key as NSString)
  }

  // MARK: Private

  private static let defaultCacheCountLimit = 100

  private let cache = NSCache<NSString, DotLottieCacheObject>()
}

// MARK: Sendable

// DotLottieCacheProvider has a Sendable requirement, but we can't
// redesign DotLottieCache to be properly Sendable without making breaking changes.
// swiftlint:disable:next no_unchecked_sendable
extension DotLottieCache: @unchecked Sendable { }
