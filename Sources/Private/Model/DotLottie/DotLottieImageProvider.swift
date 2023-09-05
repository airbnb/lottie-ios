//
//  DotLottieImageProvider.swift
//  Lottie
//
//  Created by Evandro Hoffmann on 20/10/22.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - DotLottieImageProvider

/// An image provider that loads the images from a DotLottieFile into memory
class DotLottieImageProvider: AnimationImageProvider {

  // MARK: Lifecycle

  /// Initializes an image provider with a specific filepath.
  ///
  /// - Parameter filepath: The absolute filepath containing the images.
  ///
  init(filepath: String) {
    self.filepath = URL(fileURLWithPath: filepath)
    loadImages()
  }

  init(filepath: URL) {
    self.filepath = filepath
    loadImages()
  }

  // MARK: Internal

  let filepath: URL

  func imageForAsset(asset: ImageAsset) -> CGImage? {
    images[asset.name]
  }

  // MARK: Private

  /// This is intentionally a Dictionary instead of an NSCache. Files from a decompressed dotLottie zip archive
  /// are only valid are deleted after being read into memory. If we used an NSCache then the OS could evict
  /// the cache entries when under memory pressure, and we would have no way to reload them later.
  ///  - Ideally we would have a way to remove image data when under memory pressure, but this would require
  ///    re-decompressing the dotLottie file when requesting an image that has been loaded but then removed.
  private var images = [String: CGImage]()

  private func loadImages() {
    for url in filepath.urls {
      #if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
      if
        let data = try? Data(contentsOf: url),
        let image = UIImage(data: data)?.cgImage
      {
        images[url.lastPathComponent] = image
      }
      #elseif os(macOS)
      if
        let data = try? Data(contentsOf: url),
        let image = NSImage(data: data)?.lottie_CGImage
      {
        images[url.lastPathComponent] = image
      }
      #endif
    }
  }

}

// MARK: Hashable

extension DotLottieImageProvider: Hashable {
  static func ==(_ lhs: DotLottieImageProvider, _ rhs: DotLottieImageProvider) -> Bool {
    lhs.filepath == rhs.filepath
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(filepath)
  }

}
