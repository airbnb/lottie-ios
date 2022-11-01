//
//  DotLottieImageProvider.swift
//  Lottie
//
//  Created by Evandro Hoffmann on 20/10/22.
//

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - DotLottieImageProvider

/// An image provide that loads the images from a DotLottieFile into memory
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

  private var images = [String: CGImage]()

  private func loadImages() {
    filepath.urls.forEach {
      #if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
      if
        let data = try? Data(contentsOf: $0),
        let image = UIImage(data: data)?.cgImage
      {
        images[$0.lastPathComponent] = image
      }
      #elseif os(macOS)
      if
        let data = try? Data(contentsOf: $0),
        let image = NSImage(data: data)?.lottie_CGImage
      {
        images[$0.lastPathComponent] = image
      }
      #endif
    }
  }

}
