//
//  DotLottieImageProvider.swift
//  Lottie
//
//  Created by Evandro Hoffmann on 20/10/22.
//

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
import UIKit

/// Provides an image for a lottie animation from a provided Bundle.
public class DotLottieImageProvider: AnimationImageProvider {

  // MARK: Lifecycle

  /// Initializes an image provider with a specific filepath.
  ///
  /// - Parameter filepath: The absolute filepath containing the images.
  ///
  public init(filepath: String) {
    self.filepath = URL(fileURLWithPath: filepath)
    loadImages()
  }

  public init(filepath: URL) {
    self.filepath = filepath
    loadImages()
  }

  // MARK: Public

  public func imageForAsset(asset: ImageAsset) -> CGImage? {
    images[asset.name]?.cgImage
  }

  // MARK: Internal

  let filepath: URL

  // MARK: Private

  private var images: [String: UIImage] = [:]

  private func loadImages() {
    filepath.urls.forEach {
      if
        let data = try? Data(contentsOf: $0),
        let image = UIImage(data: data)
      {
        images[$0.lastPathComponent] = image
      }
    }
  }

}
#endif
