// Created for the watchOS port.

#if os(watchOS)
import CoreGraphics
import Foundation

/// The watchOS counterpart of the UIKit `BundleImageProvider`.
///
/// Same contract - look an asset up in a bundle, optionally under a
/// subdirectory - but it decodes through ImageIO, because importing UIKit here
/// would re-export the SDK's gated CoreAnimation over the shim for the whole
/// module. Asset-catalogue lookup is not supported, as `NSDataAsset` is itself
/// UIKit; images referenced by filename, which is what exported Lottie files
/// use, work exactly as they do elsewhere.
public final class BundleImageProvider: AnimationImageProvider {

  // MARK: Lifecycle

  public init(bundle: Bundle, searchPath: String?) {
    self.bundle = bundle
    self.searchPath = searchPath
  }

  // MARK: Public

  public func imageForAsset(asset: ImageAsset) -> CGImage? {
    if asset.name.hasPrefix("data:"), let data = Data(imageAsset: asset) {
      return lottieDecodeCGImage(data)
    }
    let directory = [searchPath, asset.directory.isEmpty ? nil : asset.directory]
      .compactMap { $0 }
      .joined(separator: "/")
    let name = (asset.name as NSString).deletingPathExtension
    let ext = (asset.name as NSString).pathExtension
    guard
      let url = bundle.url(
        forResource: name,
        withExtension: ext.isEmpty ? nil : ext,
        subdirectory: directory.isEmpty ? nil : directory
      ),
      let data = try? Data(contentsOf: url)
    else { return nil }
    return lottieDecodeCGImage(data)
  }

  // MARK: Internal

  let bundle: Bundle
  let searchPath: String?
}
#endif
