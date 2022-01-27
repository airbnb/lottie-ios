//
//  FilepathImageProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/1/19.
//

#if os(macOS)
import AppKit

/**
 An `AnimationImageProvider` that provides images by name from a specific filepath.
 */
public class FilepathImageProvider: AnimationImageProvider {

  // MARK: Lifecycle

  /**
   Initializes an image provider with a specific filepath.

   - Parameter filepath: The absolute filepath containing the images.

   */
  public init(filepath: String) {
    self.filepath = URL(fileURLWithPath: filepath)
  }

  public init(filepath: URL) {
    self.filepath = filepath
  }

  // MARK: Public

  public func imageForAsset(asset: ImageAsset) -> CGImage? {

    if
      asset.name.hasPrefix("data:"),
      let url = URL(string: asset.name),
      let data = try? Data(contentsOf: url),
      let image = NSImage(data: data)
    {
      return image.CGImage
    }

    let directPath = filepath.appendingPathComponent(asset.name).path
    if FileManager.default.fileExists(atPath: directPath) {

      return NSImage(contentsOfFile: directPath)?.CGImage
    }

    let pathWithDirectory = filepath.appendingPathComponent(asset.directory).appendingPathComponent(asset.name).path
    if FileManager.default.fileExists(atPath: pathWithDirectory) {
      return NSImage(contentsOfFile: pathWithDirectory)?.CGImage
    }

    LottieLogger.shared.assertionFailure("Could not find image \"\(asset.name)\" in bundle")
    return nil
  }

  // MARK: Internal

  let filepath: URL
}

extension NSImage {
  @nonobjc
  var CGImage: CGImage? {
    get {
      guard let imageData = tiffRepresentation else { return nil }
      guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
      return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
    }
  }
}
#endif
