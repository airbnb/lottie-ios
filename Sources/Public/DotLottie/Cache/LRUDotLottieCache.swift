//
//  LRUDotLottieCache.swift
//  Lottie
//
//  Created by Evandro Hoffmann on 20/10/22.
//

import Foundation

/// A DotLottie Cache that will store lottie files up to `cacheSize`.
///
/// Once `cacheSize` is reached, the least recently used lottie will be ejected.
/// The default size of the cache is 100.
public class LRUDotLottieCache: DotLottieCacheProvider {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  /// The global shared Cache.
  public static let sharedCache = LRUDotLottieCache()

  /// The size of the cache.
  public var cacheSize = 100

  /// Clears the Cache.
  public func clearCache() {
    cacheMap.removeAll()
    lruList.removeAll()
  }

  public func file(forKey: String) -> DotLottie? {
    guard let lottie = cacheMap[forKey] else {
      return nil
    }
    if let index = lruList.firstIndex(of: forKey) {
      lruList.remove(at: index)
      lruList.append(forKey)
    }
    return lottie
  }

  public func setFile(_ lottie: DotLottie, forKey: String) {
    cacheMap[forKey] = lottie
    lruList.append(forKey)
    if lruList.count > cacheSize {
      let removed = lruList.remove(at: 0)
      if removed != forKey {
        cacheMap[removed] = nil
      }
    }
  }

  // MARK: Fileprivate

  fileprivate var cacheMap: [String: DotLottie] = [:]
  fileprivate var lruList: [String] = []

}
