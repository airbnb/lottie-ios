//
//  CompatibleImageProvider.swift
//  Lottie_iOS
//

import CoreGraphics
import Foundation

#if canImport(UIKit)
import UIKit

/// An Objective-C compatible protocol for providing images to Lottie.
@objc
public protocol CompatibleAnimationImageProvider: NSObjectProtocol {
  /// The image to display for the given asset name defined in the `LottieAnimation` JSON file.
  @objc
  func imageForAsset(name: String) -> CGImage?
}

/// An internal wrapper that converts a `CompatibleAnimationImageProvider` to a Lottie `AnimationImageProvider`.
final class CompatibleImageProvider: AnimationImageProvider {

  // MARK: Lifecycle

  init(imageProvider: CompatibleAnimationImageProvider) {
    self.imageProvider = imageProvider
  }

  // MARK: Internal

  let imageProvider: CompatibleAnimationImageProvider

  func imageForAsset(asset: ImageAsset) -> CGImage? {
    imageProvider.imageForAsset(name: asset.name)
  }
}

extension CompatibleImageProvider: Equatable {
  static func ==(lhs: CompatibleImageProvider, rhs: CompatibleImageProvider) -> Bool {
    lhs.imageProvider.isEqual(rhs.imageProvider)
  }
}
#endif
