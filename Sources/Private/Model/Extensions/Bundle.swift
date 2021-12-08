import Foundation
#if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

extension Bundle {
  func getAnimationData(_ name: String, subdirectory: String? = nil) throws -> Data? {
    // Check for files in the bundle at the given path
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
}
