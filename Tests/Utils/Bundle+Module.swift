// Created by Cal Stephens on 1/25/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Foundation

extension Bundle {
  /// The Bundle representing files in this module
  static var module: Bundle {
    Bundle(for: SnapshotTests.self)
  }

  /// Retrieves URLs for all of the files in the given directory with the given suffix
  func fileURLs(in directory: String, withSuffix suffix: String) -> [URL] {
    let enumerator = FileManager.default.enumerator(atPath: Bundle.module.bundlePath)!

    var fileURLs: [URL] = []

    while let fileSubpath = enumerator.nextObject() as? String {
      if
        fileSubpath.hasPrefix(directory),
        fileSubpath.contains(suffix)
      {
        let fileURL = Bundle.module.bundleURL.appendingPathComponent(fileSubpath)
        fileURLs.append(fileURL)
      }
    }

    return fileURLs
  }
}
