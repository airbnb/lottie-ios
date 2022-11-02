import Foundation
#if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

extension Bundle {
  func getAnimationData(_ name: String, subdirectory: String? = nil) throws -> Data? {
    // Check for files in the bundle at the given path
    let name = name.removingJSONSuffix()
    if let url = url(forResource: name, withExtension: "json", subdirectory: subdirectory) {
      return try Data(contentsOf: url)
    }

    // Check for data assets (not available on macOS)
    #if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
    let assetKey = subdirectory != nil ? "\(subdirectory ?? "")/\(name)" : name
    return NSDataAsset(name: assetKey, bundle: self)?.data
    #else
    return nil
    #endif
  }

  func dotLottieData(_ name: String, subdirectory: String? = nil) throws -> Data? {
    // Check for files in the bundle at the given path
    let name = name.removingDotLottieSuffix()
    if let url = url(forResource: name, withExtension: "lottie", subdirectory: subdirectory) {
      return try Data(contentsOf: url)
    }

    // Check for data assets (not available on macOS)
    #if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
    let assetKey = subdirectory != nil ? "\(subdirectory ?? "")/\(name)" : name
    return NSDataAsset(name: assetKey, bundle: self)?.data
    #else
    return nil
    #endif
  }
}

extension String {
  fileprivate func removingJSONSuffix() -> String {
    // Allow filenames to be passed with a ".json" extension (but not other extensions)
    // to keep the behavior from Lottie 2.x - instead of failing to load the animation
    guard hasSuffix(".json") else {
      return self
    }

    return (self as NSString).deletingPathExtension
  }

  fileprivate func removingDotLottieSuffix() -> String {
    // Allow filenames to be passed with a ".lottie" extension (but not other extensions)
    // to keep the behavior from Lottie 2.x - instead of failing to load the file
    guard hasSuffix(".lottie") else {
      return self
    }

    return (self as NSString).deletingPathExtension
  }
}
