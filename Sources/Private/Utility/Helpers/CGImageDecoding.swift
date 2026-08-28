// Created by Cal Stephens on 8/28/26.
// Copyright © 2026 Airbnb Inc. All rights reserved.

import CoreGraphics
import Foundation

#if os(watchOS)
import ImageIO
#elseif canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Decodes image data into a `CGImage`.
///
/// watchOS deliberately does not go through UIKit here. Importing UIKit on
/// watchOS re-exports the SDK's CoreAnimation declarations - the ones marked
/// `API_UNAVAILABLE(watchos)` - and because Swift compiles a module as a
/// whole, a single file importing it makes those gated declarations win over
/// `CAShim` for *every* file in the library. ImageIO reads the same bytes with
/// no such side effect.
func lottieDecodeCGImage(_ data: Data) -> CGImage? {
  #if os(watchOS)
  guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
  return CGImageSourceCreateImageAtIndex(source, 0, nil)
  #elseif canImport(UIKit)
  return UIImage(data: data)?.cgImage
  #elseif canImport(AppKit)
  return NSImage(data: data)?.lottie_CGImage
  #else
  return nil
  #endif
}
