//
//  AnimationCacheProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/5/19.
//

import Foundation
/// `AnimationCacheProvider` is a protocol that describes an Animation Cache.
/// Animation Cache is used when loading `LottieAnimation` models. Using an Animation Cache
/// can increase performance when loading an animation multiple times.
///
/// Lottie comes with a prebuilt LRU Animation Cache.
public protocol AnimationCacheProvider: AnyObject {

  func animation(forKey: String) -> LottieAnimation?

  func setAnimation(_ animation: LottieAnimation, forKey: String)

  func clearCache()

}
