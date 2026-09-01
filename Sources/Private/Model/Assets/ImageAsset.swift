//
//  ImageAsset.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

import CoreGraphics
import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - ImageAsset

public final class ImageAsset: Asset {

  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ImageAsset.CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    directory = try container.decode(String.self, forKey: .directory)
    width = try container.decode(Double.self, forKey: .width)
    height = try container.decode(Double.self, forKey: .height)
    try super.init(from: decoder)
  }

  required init(dictionary: [String: Any]) throws {
    name = try dictionary.value(for: CodingKeys.name)
    directory = try dictionary.value(for: CodingKeys.directory)
    width = try dictionary.value(for: CodingKeys.width)
    height = try dictionary.value(for: CodingKeys.height)
    try super.init(dictionary: dictionary)
  }

  // MARK: Public

  /// Image name
  public let name: String

  /// Image Directory
  public let directory: String

  /// Image Size
  public let width: Double

  public let height: Double

  override public func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(directory, forKey: .directory)
    try container.encode(width, forKey: .width)
    try container.encode(height, forKey: .height)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case name = "p"
    case directory = "u"
    case width = "w"
    case height = "h"
  }
}

extension Data {

  // MARK: Lifecycle

  /// Initializes `Data` from an `ImageAsset`.
  ///
  /// Returns nil when the input is not recognized as valid Data URL.
  /// - parameter imageAsset: The image asset that contains Data URL.
  init?(imageAsset: ImageAsset) {
    self.init(dataString: imageAsset.name)
  }

  /// Initializes `Data` from a [Data URL](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs) String.
  ///
  /// Returns nil when the input is not recognized as valid Data URL.
  /// - parameter dataString: The data string to parse.
  /// - parameter options: Options for the string parsing. Default value is `[]`.
  init?(dataString: String, options: DataURLReadOptions = []) {
    let trimmedDataString = dataString.trimmingCharacters(in: .whitespacesAndNewlines)
    guard
      dataString.hasPrefix("data:"),
      let url = URL(string: trimmedDataString)
    else {
      return nil
    }
    // The code below is needed because Data(contentsOf:) floods logs
    // with messages since url doesn't have a host. This only fixes flooding logs
    // when data inside Data URL is base64 encoded.
    if
      let base64Range = trimmedDataString.range(of: ";base64,"),
      !options.contains(DataURLReadOptions.legacy)
    {
      let encodedString = String(trimmedDataString[base64Range.upperBound...])
      // Foundation's Data(base64Encoded:) can raise NSMallocException on allocation failure.
      // Decode in Swift so malformed or oversized payloads fail gracefully.
      self.init(swiftBase64Encoded: encodedString)
    } else {
      try? self.init(contentsOf: url)
    }
  }

  /// Initializes `Data` from a base64 encoded string using a Swift decoder.
  ///
  /// Returns nil when the input is not valid base64 or exceeds the maximum supported size.
  init?(swiftBase64Encoded string: String) {
    guard let decoded = Base64Decoder.decode(string) else {
      return nil
    }
    self = decoded
  }

  // MARK: Internal

  struct DataURLReadOptions: OptionSet {
    /// Will read Data URL using Data(contentsOf:)
    static let legacy = DataURLReadOptions(rawValue: 1 << 0)

    let rawValue: Int

  }

}

// MARK: - Base64Decoder

/// A small Swift base64 decoder that avoids Foundation APIs which can raise NSMallocException.
private enum Base64Decoder {

  // MARK: Internal

  /// Maximum decoded payload size for embedded image assets (64 MB).
  static let maxDecodedByteCount = 64 * 1024 * 1024

  static func decode(_ string: String) -> Data? {
    let utf8 = Array(string.utf8)
    guard !utf8.isEmpty, utf8.count.isMultiple(of: 4) else { return nil }

    let estimatedDecodedLength = utf8.count * 3 / 4
    guard estimatedDecodedLength <= maxDecodedByteCount else { return nil }

    var bytes = [UInt8]()
    bytes.reserveCapacity(estimatedDecodedLength)

    var buffer: UInt32 = 0
    var bitsCollected = 0

    for byte in utf8 {
      if byte == UInt8(ascii: "=") {
        break
      }

      guard let value = reverseLookup[byte] else {
        return nil
      }

      buffer = (buffer << 6) | UInt32(value)
      bitsCollected += 6

      if bitsCollected >= 8 {
        bitsCollected -= 8
        bytes.append(UInt8((buffer >> bitsCollected) & 0xFF))
      }
    }

    return Data(bytes)
  }

  // MARK: Private

  private static let reverseLookup: [UInt8: UInt8] = {
    var map = [UInt8: UInt8]()
    for (index, character) in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".utf8.enumerated() {
      map[character] = UInt8(index)
    }
    return map
  }()

}

extension ImageAsset {
  /// A `CGImage` loaded from this asset if represented using a Base 64 encoding
  var base64Image: CGImage? {
    guard let data = Data(imageAsset: self) else { return nil }

    #if canImport(UIKit)
    return UIImage(data: data)?.cgImage
    #elseif canImport(AppKit)
    return NSImage(data: data)?.lottie_CGImage
    #endif
  }
}

// MARK: - ImageAsset + @unchecked Sendable

/// `ImageAsset` inherits `@unchecked Sendable` from `Asset` and
/// we need to restate that here to avoid a warning in Xcode 16
// swiftlint:disable:next no_unchecked_sendable
extension ImageAsset: @unchecked Sendable { }
