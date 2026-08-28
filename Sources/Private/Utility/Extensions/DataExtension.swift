//
//  DataExtension.swift
//  Lottie
//
//  Created by René Fouquet on 03.05.21.
//

import Foundation
#if canImport(UIKit)
#if !os(watchOS)
import UIKit
#endif
#elseif canImport(AppKit)
import AppKit
#endif

extension Data {

  init(assetName: String, in bundle: Bundle) throws {
    #if os(watchOS)
    // NSDataAsset lives in UIKit, which this build cannot import. Animations
    // still load from files and from Data; only asset-catalogue lookup is out.
    throw DotLottieError.assetNotFound(name: assetName, bundle: bundle)
    #elseif canImport(UIKit)
    if let asset = NSDataAsset(name: assetName, bundle: bundle) {
      self = asset.data
      return
    } else {
      throw DotLottieError.assetNotFound(name: assetName, bundle: bundle)
    }
    #else
    if let asset = NSDataAsset(name: assetName, bundle: bundle) {
      self = asset.data
      return
    } else {
      throw DotLottieError.assetNotFound(name: assetName, bundle: bundle)
    }
    #endif
  }
}
