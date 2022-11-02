//
//  Entry.swift
//  ZIPFoundation
//
//  Copyright © 2017-2021 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
//  Released under the MIT License.
//
//  See https://github.com/weichsel/ZIPFoundation/blob/master/LICENSE for license information.
//

import CoreFoundation
import Foundation

// MARK: - ZipEntry

/// A value that represents a file, a directory or a symbolic link within a ZIP `Archive`.
///
/// You can retrieve instances of `Entry` from an `Archive` via subscripting or iteration.
/// Entries are identified by their `path`.
struct ZipEntry: Equatable {

  // MARK: Lifecycle

  init?(
    centralDirectoryStructure: CentralDirectoryStructure,
    localFileHeader: LocalFileHeader,
    dataDescriptor: DefaultDataDescriptor? = nil,
    zip64DataDescriptor: ZIP64DataDescriptor? = nil)
  {
    // We currently don't support encrypted archives
    guard !centralDirectoryStructure.isEncrypted else { return nil }
    self.centralDirectoryStructure = centralDirectoryStructure
    self.localFileHeader = localFileHeader
    self.dataDescriptor = dataDescriptor
    self.zip64DataDescriptor = zip64DataDescriptor
  }

  // MARK: Internal

  struct LocalFileHeader: DataSerializable {
    let localFileHeaderSignature = UInt32(localFileHeaderStructSignature)
    let versionNeededToExtract: UInt16
    let generalPurposeBitFlag: UInt16
    let compressionMethod: UInt16
    let lastModFileTime: UInt16
    let lastModFileDate: UInt16
    let crc32: UInt32
    let compressedSize: UInt32
    let uncompressedSize: UInt32
    let fileNameLength: UInt16
    let extraFieldLength: UInt16
    static let size = 30
    let fileNameData: Data
    let extraFieldData: Data
    var extraFields: [ExtensibleDataField]?
  }

  struct DataDescriptor<T: BinaryInteger>: DataSerializable {
    let data: Data
    let dataDescriptorSignature = UInt32(dataDescriptorStructSignature)
    let crc32: UInt32
    // For normal archives, the compressed and uncompressed sizes are 4 bytes each.
    // For ZIP64 format archives, the compressed and uncompressed sizes are 8 bytes each.
    let compressedSize: T
    let uncompressedSize: T
    static var memoryLengthOfSize: Int { MemoryLayout<T>.size }
    static var size: Int { memoryLengthOfSize * 2 + 8 }
  }

  typealias DefaultDataDescriptor = DataDescriptor<UInt32>
  typealias ZIP64DataDescriptor = DataDescriptor<UInt64>

  struct CentralDirectoryStructure: DataSerializable {
    static let size = 46

    let centralDirectorySignature = UInt32(centralDirectoryStructSignature)
    let versionMadeBy: UInt16
    let versionNeededToExtract: UInt16
    let generalPurposeBitFlag: UInt16
    let compressionMethod: UInt16
    let lastModFileTime: UInt16
    let lastModFileDate: UInt16
    let crc32: UInt32
    let compressedSize: UInt32
    let uncompressedSize: UInt32
    let fileNameLength: UInt16
    let extraFieldLength: UInt16
    let fileCommentLength: UInt16
    let diskNumberStart: UInt16
    let internalFileAttributes: UInt16
    let externalFileAttributes: UInt32
    let relativeOffsetOfLocalHeader: UInt32
    let fileNameData: Data
    let extraFieldData: Data
    let fileCommentData: Data

    var extraFields: [ExtensibleDataField]?

    var usesDataDescriptor: Bool { (generalPurposeBitFlag & (1 << 3)) != 0 }
    var usesUTF8PathEncoding: Bool { (generalPurposeBitFlag & (1 << 11)) != 0 }
    var isEncrypted: Bool { (generalPurposeBitFlag & (1 << 0)) != 0 }
    var isZIP64: Bool {
      // If ZIP64 extended information is existing, try to treat cd as ZIP64 format
      // even if the version needed to extract is lower than 4.5
      UInt8(truncatingIfNeeded: versionNeededToExtract) >= 45 || zip64ExtendedInformation != nil
    }
  }

  static let localFileHeaderStructSignature = 0x04034b50
  static let dataDescriptorStructSignature = 0x08074b50
  static let centralDirectoryStructSignature = 0x02014b50

  let centralDirectoryStructure: CentralDirectoryStructure
  let localFileHeader: LocalFileHeader
  let dataDescriptor: DefaultDataDescriptor?
  let zip64DataDescriptor: ZIP64DataDescriptor?

  /// The `path` of the receiver within a ZIP `Archive`.
  var path: String {
    let dosLatinUS = 0x400
    let dosLatinUSEncoding = CFStringEncoding(dosLatinUS)
    let dosLatinUSStringEncoding = CFStringConvertEncodingToNSStringEncoding(dosLatinUSEncoding)
    let codepage437 = String.Encoding(rawValue: dosLatinUSStringEncoding)
    let encoding = centralDirectoryStructure.usesUTF8PathEncoding ? .utf8 : codepage437
    return self.path(using: encoding)
  }

  /// The file attributes of the receiver as key/value pairs.
  ///
  /// Contains the modification date and file permissions.
  var fileAttributes: [FileAttributeKey: Any] {
    FileManager.attributes(from: self)
  }

  /// The `CRC32` checksum of the receiver.
  ///
  /// - Note: Always returns `0` for entries of type `EntryType.directory`.
  var checksum: UInt32 {
    if centralDirectoryStructure.usesDataDescriptor {
      return zip64DataDescriptor?.crc32 ?? dataDescriptor?.crc32 ?? 0
    }
    return centralDirectoryStructure.crc32
  }

  /// Indicates whether or not the receiver is compressed.
  var isCompressed: Bool {
    localFileHeader.compressionMethod != 0
  }

  /// The size of the receiver's compressed data.
  var compressedSize: UInt64 {
    if centralDirectoryStructure.isZIP64 {
      return zip64DataDescriptor?.compressedSize ?? centralDirectoryStructure.effectiveCompressedSize
    }
    return UInt64(dataDescriptor?.compressedSize ?? centralDirectoryStructure.compressedSize)
  }

  /// The size of the receiver's uncompressed data.
  var uncompressedSize: UInt64 {
    if centralDirectoryStructure.isZIP64 {
      return zip64DataDescriptor?.uncompressedSize ?? centralDirectoryStructure.effectiveUncompressedSize
    }
    return UInt64(dataDescriptor?.uncompressedSize ?? centralDirectoryStructure.uncompressedSize)
  }

  /// The combined size of the local header, the data and the optional data descriptor.
  var localSize: UInt64 {
    let localFileHeader = localFileHeader
    var extraDataLength = Int(localFileHeader.fileNameLength)
    extraDataLength += Int(localFileHeader.extraFieldLength)
    var size = UInt64(LocalFileHeader.size + extraDataLength)
    size += isCompressed ? compressedSize : uncompressedSize
    if centralDirectoryStructure.isZIP64 {
      size += zip64DataDescriptor != nil ? UInt64(ZIP64DataDescriptor.size) : 0
    } else {
      size += dataDescriptor != nil ? UInt64(DefaultDataDescriptor.size) : 0
    }
    return size
  }

  var dataOffset: UInt64 {
    var dataOffset = centralDirectoryStructure.effectiveRelativeOffsetOfLocalHeader
    dataOffset += UInt64(LocalFileHeader.size)
    dataOffset += UInt64(localFileHeader.fileNameLength)
    dataOffset += UInt64(localFileHeader.extraFieldLength)
    return dataOffset
  }

  static func == (lhs: ZipEntry, rhs: ZipEntry) -> Bool {
    lhs.path == rhs.path
      && lhs.localFileHeader.crc32 == rhs.localFileHeader.crc32
      && lhs.centralDirectoryStructure.effectiveRelativeOffsetOfLocalHeader
      == rhs.centralDirectoryStructure.effectiveRelativeOffsetOfLocalHeader
  }

  /// Returns the `path` of the receiver within a ZIP `Archive` using a given encoding.
  ///
  /// - Parameters:
  ///   - encoding: `String.Encoding`
  func path(using encoding: String.Encoding) -> String {
    String(data: centralDirectoryStructure.fileNameData, encoding: encoding) ?? ""
  }

}

extension ZipEntry.CentralDirectoryStructure {
  var effectiveCompressedSize: UInt64 {
    if isZIP64, let compressedSize = zip64ExtendedInformation?.compressedSize, compressedSize > 0 {
      return compressedSize
    }
    return UInt64(compressedSize)
  }

  var effectiveUncompressedSize: UInt64 {
    if isZIP64, let uncompressedSize = zip64ExtendedInformation?.uncompressedSize, uncompressedSize > 0 {
      return uncompressedSize
    }
    return UInt64(uncompressedSize)
  }

  var effectiveRelativeOffsetOfLocalHeader: UInt64 {
    if isZIP64, let offset = zip64ExtendedInformation?.relativeOffsetOfLocalHeader, offset > 0 {
      return offset
    }
    return UInt64(relativeOffsetOfLocalHeader)
  }
}
