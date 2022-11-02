//
//  FileManager+ZIP.swift
//  ZIPFoundation
//
//  Copyright © 2017-2021 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
//  Released under the MIT License.
//
//  See https://github.com/weichsel/ZIPFoundation/blob/master/LICENSE for license information.
//

import Foundation

extension FileManager {

  /// The default permissions for newly added entries.
  static let defaultFilePermissions = UInt16(0o644)

  class func attributes(from entry: ZipEntry) -> [FileAttributeKey: Any] {
    let centralDirectoryStructure = entry.centralDirectoryStructure
    let fileTime = centralDirectoryStructure.lastModFileTime
    let fileDate = centralDirectoryStructure.lastModFileDate
    let defaultPermissions = defaultFilePermissions
    var attributes = [.posixPermissions: defaultPermissions] as [FileAttributeKey: Any]
    // Certain keys are not yet supported in swift-corelibs
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    attributes[.modificationDate] = Date(dateTime: (fileDate, fileTime))
    #endif
    let externalFileAttributes = centralDirectoryStructure.externalFileAttributes
    let permissions = permissions(for: externalFileAttributes)
    attributes[.posixPermissions] = NSNumber(value: permissions)
    return attributes
  }

  class func permissions(for externalFileAttributes: UInt32) -> UInt16 {
    let permissions = mode_t(externalFileAttributes >> 16) & ~S_IFMT
    let defaultPermissions = defaultFilePermissions
    return permissions == 0 ? defaultPermissions : UInt16(permissions)
  }

  /// Unzips the contents at the specified source URL to the destination URL.
  ///
  /// - Parameters:
  ///   - sourceURL: The file URL pointing to an existing ZIP file.
  ///   - destinationURL: The file URL that identifies the destination directory of the unzip operation.
  /// - Throws: Throws an error if the source item does not exist or the destination URL is not writable.
  func unzipItem(at sourceURL: URL, to destinationURL: URL) throws {
    guard (try? sourceURL.checkResourceIsReachable()) == true else {
      throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: sourceURL.path])
    }
    guard let archive = ZipArchive(url: sourceURL) else {
      throw ZipArchive.ArchiveError.unreadableArchive
    }

    for entry in archive {
      let path = entry.path
      let entryURL = destinationURL.appendingPathComponent(path)
      guard entryURL.isContained(in: destinationURL) else {
        throw CocoaError(
          .fileReadInvalidFileName,
          userInfo: [NSFilePathErrorKey: entryURL.path])
      }
      let crc32: UInt32 = try archive.extract(entry, to: entryURL)

      func verifyChecksumIfNecessary() throws {
        if crc32 != entry.checksum {
          throw ZipArchive.ArchiveError.invalidCRC32
        }
      }
      try verifyChecksumIfNecessary()
    }
  }

  // MARK: - Helpers

  func createParentDirectoryStructure(for url: URL) throws {
    let parentDirectoryURL = url.deletingLastPathComponent()
    try createDirectory(at: parentDirectoryURL, withIntermediateDirectories: true, attributes: nil)
  }

}

extension Date {
  fileprivate init(dateTime: (UInt16, UInt16)) {
    var msdosDateTime = Int(dateTime.0)
    msdosDateTime <<= 16
    msdosDateTime |= Int(dateTime.1)
    var unixTime = tm()
    unixTime.tm_sec = Int32((msdosDateTime & 31) * 2)
    unixTime.tm_min = Int32((msdosDateTime >> 5) & 63)
    unixTime.tm_hour = Int32((Int(dateTime.1) >> 11) & 31)
    unixTime.tm_mday = Int32((msdosDateTime >> 16) & 31)
    unixTime.tm_mon = Int32((msdosDateTime >> 21) & 15)
    unixTime.tm_mon -= 1 // UNIX time struct month entries are zero based.
    unixTime.tm_year = Int32(1980 + (msdosDateTime >> 25))
    unixTime.tm_year -= 1900 // UNIX time structs count in "years since 1900".
    let time = timegm(&unixTime)
    self = Date(timeIntervalSince1970: TimeInterval(time))
  }
}

#if swift(>=4.2)
#else

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
#else

// The swift-corelibs-foundation version of NSError.swift was missing a convenience method to create
// error objects from error codes. (https://github.com/apple/swift-corelibs-foundation/pull/1420)
// We have to provide an implementation for non-Darwin platforms using Swift versions < 4.2.

extension CocoaError {
  fileprivate static func error(_ code: CocoaError.Code, userInfo: [AnyHashable: Any]? = nil, url: URL? = nil) -> Error {
    var info: [String: Any] = userInfo as? [String: Any] ?? [:]
    if let url = url {
      info[NSURLErrorKey] = url
    }
    return NSError(domain: NSCocoaErrorDomain, code: code.rawValue, userInfo: info)
  }
}

#endif
#endif

extension URL {
  fileprivate func isContained(in parentDirectoryURL: URL) -> Bool {
    // Ensure this URL is contained in the passed in URL
    let parentDirectoryURL = URL(fileURLWithPath: parentDirectoryURL.path, isDirectory: true).standardized
    return standardized.absoluteString.hasPrefix(parentDirectoryURL.absoluteString)
  }
}
