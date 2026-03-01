//
//  CompatibleFontProvider.swift
//  Lottie_iOS
//

import CoreText
import Foundation

#if canImport(UIKit)
import UIKit
/// An Objective-C compatible protocol for providing fonts to Lottie.
@objc
public protocol CompatibleAnimationFontProvider: NSObjectProtocol {
  @objc
  func fontFor(family: String, size: CGFloat) -> CTFont?
}

/// An internal wrapper that converts a `CompatibleAnimationFontProvider` to a Lottie `AnimationFontProvider`.
final class CompatibleFontProvider: AnimationFontProvider {

  // MARK: Lifecycle

  init(fontProvider: CompatibleAnimationFontProvider) {
    self.fontProvider = fontProvider
  }

  // MARK: Internal

  let fontProvider: CompatibleAnimationFontProvider

  func fontFor(family: String, size: CGFloat) -> CTFont? {
    fontProvider.fontFor(family: family, size: size)
  }
}

extension CompatibleFontProvider: Equatable {
  static func ==(lhs: CompatibleFontProvider, rhs: CompatibleFontProvider) -> Bool {
    lhs.fontProvider.isEqual(rhs.fontProvider)
  }
}
#endif
