//
//  DotLottieCacheProvider.swift
//  Lottie
//
//  Created by Evandro Hoffmann on 20/10/22.
//

import Foundation
/// `DotLottieCacheProvider` is a protocol that describes a DotLottie Cache.
/// DotLottie Cache is used when loading `DotLottie` models. Using a DotLottie Cache
/// can increase performance when loading an animation multiple times.
///
/// Lottie comes with a prebuilt LRU DotLottie Cache.
public protocol DotLottieCacheProvider {

  func file(forKey: String) -> DotLottie?

  func setFile(_ lottie: DotLottie, forKey: String)

  func clearCache()

}
