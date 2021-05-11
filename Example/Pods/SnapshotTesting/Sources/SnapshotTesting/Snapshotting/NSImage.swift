#if os(macOS)
import Cocoa
import XCTest

extension Diffing where Value == NSImage {
  /// A pixel-diffing strategy for NSImage's which requires a 100% match.
  public static let image = Diffing.image(precision: 1)

  /// A pixel-diffing strategy for NSImage that allows customizing how precise the matching must be.
  ///
  /// - Parameter precision: A value between 0 and 1, where 1 means the images must match 100% of their pixels.
  /// - Returns: A new diffing strategy.
  public static func image(precision: Float) -> Diffing {
    return .init(
      toData: { NSImagePNGRepresentation($0)! },
      fromData: { NSImage(data: $0)! }
    ) { old, new in
      guard !compare(old, new, precision: precision) else { return nil }
      let difference = SnapshotTesting.diff(old, new)
      let message = new.size == old.size
        ? "Newly-taken snapshot does not match reference."
        : "Newly-taken snapshot@\(new.size) does not match reference@\(old.size)."
      return (
        message,
        [XCTAttachment(image: old), XCTAttachment(image: new), XCTAttachment(image: difference)]
      )
    }
  }
}

extension Snapshotting where Value == NSImage, Format == NSImage {
  /// A snapshot strategy for comparing images based on pixel equality.
  public static var image: Snapshotting {
    return .image(precision: 1)
  }

  /// A snapshot strategy for comparing images based on pixel equality.
  ///
  /// - Parameter precision: The percentage of pixels that must match.
  public static func image(precision: Float) -> Snapshotting {
    return .init(
      pathExtension: "png",
      diffing: .image(precision: precision)
    )
  }
}

private func NSImagePNGRepresentation(_ image: NSImage) -> Data? {
  guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
  let rep = NSBitmapImageRep(cgImage: cgImage)
  rep.size = image.size
  return rep.representation(using: .png, properties: [:])
}

private func compare(_ old: NSImage, _ new: NSImage, precision: Float) -> Bool {
  guard let oldCgImage = old.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
  guard let newCgImage = new.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
  guard oldCgImage.width != 0 else { return false }
  guard newCgImage.width != 0 else { return false }
  guard oldCgImage.width == newCgImage.width else { return false }
  guard oldCgImage.height != 0 else { return false }
  guard newCgImage.height != 0 else { return false }
  guard oldCgImage.height == newCgImage.height else { return false }
  guard let oldContext = context(for: oldCgImage) else { return false }
  guard let newContext = context(for: newCgImage) else { return false }
  guard let oldData = oldContext.data else { return false }
  guard let newData = newContext.data else { return false }
  let byteCount = oldContext.height * oldContext.bytesPerRow
  if memcmp(oldData, newData, byteCount) == 0 { return true }
  let newer = NSImage(data: NSImagePNGRepresentation(new)!)!
  guard let newerCgImage = newer.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
  guard let newerContext = context(for: newerCgImage) else { return false }
  guard let newerData = newerContext.data else { return false }
  if memcmp(oldData, newerData, byteCount) == 0 { return true }
  if precision >= 1 { return false }
  let oldRep = NSBitmapImageRep(cgImage: oldCgImage)
  let newRep = NSBitmapImageRep(cgImage: newerCgImage)
  var differentPixelCount = 0
  let pixelCount = oldRep.pixelsWide * oldRep.pixelsHigh
  let threshold = 1 - precision
  for x in 0..<oldRep.pixelsWide {
    for y in 0..<oldRep.pixelsHigh {
      if oldRep.colorAt(x: x, y: y) != newRep.colorAt(x: x, y: y) { differentPixelCount += 1 }
      if Float(differentPixelCount) / Float(pixelCount) > threshold { return false}
    }
  }
  return true
}

private func context(for cgImage: CGImage) -> CGContext? {
  guard
    let space = cgImage.colorSpace,
    let context = CGContext(
      data: nil,
      width: cgImage.width,
      height: cgImage.height,
      bitsPerComponent: cgImage.bitsPerComponent,
      bytesPerRow: cgImage.bytesPerRow,
      space: space,
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )
    else { return nil }

  context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
  return context
}

private func diff(_ old: NSImage, _ new: NSImage) -> NSImage {
  let oldCiImage = CIImage(cgImage: old.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
  let newCiImage = CIImage(cgImage: new.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
  let differenceFilter = CIFilter(name: "CIDifferenceBlendMode")!
  differenceFilter.setValue(oldCiImage, forKey: kCIInputImageKey)
  differenceFilter.setValue(newCiImage, forKey: kCIInputBackgroundImageKey)
  let maxSize = CGSize(
    width: max(old.size.width, new.size.width),
    height: max(old.size.height, new.size.height)
  )
  let rep = NSCIImageRep(ciImage: differenceFilter.outputImage!)
  let difference = NSImage(size: maxSize)
  difference.addRepresentation(rep)
  return difference
}
#endif
