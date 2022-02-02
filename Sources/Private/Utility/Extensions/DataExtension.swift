//
//  DataExtension.swift
//  Lottie
//
//  Created by René Fouquet on 03.05.21.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Data {

  static func jsonData(from assetName: String, in bundle: Bundle) -> Data? {
    #if canImport(UIKit)
    return NSDataAsset(name: assetName, bundle: bundle)?.data
    #else
    if #available(macOS 10.11, *) {
      return NSDataAsset(name: assetName, bundle: bundle)?.data
    }
    return nil
    #endif
  }
}
