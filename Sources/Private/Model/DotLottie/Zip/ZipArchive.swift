//
//  Archive.swift
//  ZIPFoundation
//
//  Copyright © 2017-2021 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
//  Released under the MIT License.
//
//  See https://github.com/weichsel/ZIPFoundation/blob/master/LICENSE for license information.
//

import Foundation

// MARK: - ZipArchive

final class ZipArchive: Sequence {

  // MARK: Lifecycle

  /// Initializes a new ZIP `Archive`.
  ///
  /// You can use this initalizer to create new archive files or to read and update existing ones.
  /// - Parameters:
  ///   - url: File URL to the receivers backing file.
  /// - Returns: An archive initialized with a backing file at the passed in file URL and the given access mode
  ///   or `nil` if the following criteria are not met:
  init?(url: URL) {
    self.url = url
    guard let config = ZipArchive.makeBackingConfiguration(for: url) else { return nil }
    archiveFile = config.file
    endOfCentralDirectoryRecord = config.endOfCentralDirectoryRecord
    zip64EndOfCentralDirectory = config.zip64EndOfCentralDirectory
    setvbuf(archiveFile, nil, _IOFBF, Int(Self.defaultPOSIXBufferSize))
  }

  deinit {
    fclose(self.archiveFile)
  }

  // MARK: Internal

  typealias LocalFileHeader = ZipEntry.LocalFileHeader
  typealias DataDescriptor = ZipEntry.DefaultDataDescriptor
  typealias ZIP64DataDescriptor = ZipEntry.ZIP64DataDescriptor
  typealias CentralDirectoryStructure = ZipEntry.CentralDirectoryStructure

  /// An error that occurs during reading, creating or updating a ZIP file.
  enum ArchiveError: Error {
    /// Thrown when an archive file is either damaged or inaccessible.
    case unreadableArchive
    /// Thrown when an archive is either opened with AccessMode.read or the destination file is unwritable.
    case unwritableArchive
    /// Thrown when the path of an `Entry` cannot be stored in an archive.
    case invalidEntryPath
    /// Thrown when an `Entry` can't be stored in the archive with the proposed compression method.
    case invalidCompressionMethod
    /// Thrown when the stored checksum of an `Entry` doesn't match the checksum during reading.
    case invalidCRC32
    /// Thrown when an extract, add or remove operation was canceled.
    case cancelledOperation
    /// Thrown when an extract operation was called with zero or negative `bufferSize` parameter.
    case invalidBufferSize
    /// Thrown when uncompressedSize/compressedSize exceeds `Int64.max` (Imposed by file API).
    case invalidEntrySize
    /// Thrown when the offset of local header data exceeds `Int64.max` (Imposed by file API).
    case invalidLocalHeaderDataOffset
    /// Thrown when the size of local header exceeds `Int64.max` (Imposed by file API).
    case invalidLocalHeaderSize
    /// Thrown when the offset of central directory exceeds `Int64.max` (Imposed by file API).
    case invalidCentralDirectoryOffset
    /// Thrown when the size of central directory exceeds `UInt64.max` (Imposed by ZIP specification).
    case invalidCentralDirectorySize
    /// Thrown when number of entries in central directory exceeds `UInt64.max` (Imposed by ZIP specification).
    case invalidCentralDirectoryEntryCount
    /// Thrown when an archive does not contain the required End of Central Directory Record.
    case missingEndOfCentralDirectoryRecord
  }

  struct EndOfCentralDirectoryRecord: DataSerializable {
    let endOfCentralDirectorySignature = UInt32(endOfCentralDirectoryStructSignature)
    let numberOfDisk: UInt16
    let numberOfDiskStart: UInt16
    let totalNumberOfEntriesOnDisk: UInt16
    let totalNumberOfEntriesInCentralDirectory: UInt16
    let sizeOfCentralDirectory: UInt32
    let offsetToStartOfCentralDirectory: UInt32
    let zipFileCommentLength: UInt16
    let zipFileCommentData: Data
    static let size = 22
  }

  // MARK: - Helpers

  typealias EndOfCentralDirectoryStructure = (EndOfCentralDirectoryRecord, ZIP64EndOfCentralDirectory?)

  struct BackingConfiguration {
    let file: FILEPointer
    let endOfCentralDirectoryRecord: EndOfCentralDirectoryRecord
    let zip64EndOfCentralDirectory: ZIP64EndOfCentralDirectory?

    init(
      file: FILEPointer,
      endOfCentralDirectoryRecord: EndOfCentralDirectoryRecord,
      zip64EndOfCentralDirectory: ZIP64EndOfCentralDirectory?)
    {
      self.file = file
      self.endOfCentralDirectoryRecord = endOfCentralDirectoryRecord
      self.zip64EndOfCentralDirectory = zip64EndOfCentralDirectory
    }
  }

  static let defaultPOSIXBufferSize = Int(16 * 1024)
  static let minEndOfCentralDirectoryOffset = Int64(22)
  static let endOfCentralDirectoryStructSignature = 0x06054b50

  /// The default chunk size when reading entry data from an archive.
  static let defaultReadChunkSize = Int(16 * 1024)

  /// URL of an Archive's backing file.
  let url: URL
  var archiveFile: FILEPointer
  var endOfCentralDirectoryRecord: EndOfCentralDirectoryRecord
  var zip64EndOfCentralDirectory: ZIP64EndOfCentralDirectory?

  var totalNumberOfEntriesInCentralDirectory: UInt64 {
    zip64EndOfCentralDirectory?.record.totalNumberOfEntriesInCentralDirectory
      ?? UInt64(endOfCentralDirectoryRecord.totalNumberOfEntriesInCentralDirectory)
  }

  var sizeOfCentralDirectory: UInt64 {
    zip64EndOfCentralDirectory?.record.sizeOfCentralDirectory
      ?? UInt64(endOfCentralDirectoryRecord.sizeOfCentralDirectory)
  }

  var offsetToStartOfCentralDirectory: UInt64 {
    zip64EndOfCentralDirectory?.record.offsetToStartOfCentralDirectory
      ?? UInt64(endOfCentralDirectoryRecord.offsetToStartOfCentralDirectory)
  }

  static func scanForEndOfCentralDirectoryRecord(in file: FILEPointer)
    -> EndOfCentralDirectoryStructure?
  {
    var eocdOffset: UInt64 = 0
    var index = minEndOfCentralDirectoryOffset
    fseeko(file, 0, SEEK_END)
    let archiveLength = Int64(ftello(file))
    while eocdOffset == 0, index <= archiveLength {
      fseeko(file, off_t(archiveLength - index), SEEK_SET)
      var potentialDirectoryEndTag = UInt32()
      fread(&potentialDirectoryEndTag, 1, MemoryLayout<UInt32>.size, file)
      if potentialDirectoryEndTag == UInt32(endOfCentralDirectoryStructSignature) {
        eocdOffset = UInt64(archiveLength - index)
        guard let eocd: EndOfCentralDirectoryRecord = Data.readStruct(from: file, at: eocdOffset) else {
          return nil
        }
        let zip64EOCD = scanForZIP64EndOfCentralDirectory(in: file, eocdOffset: eocdOffset)
        return (eocd, zip64EOCD)
      }
      index += 1
    }
    return nil
  }

  static func makeBackingConfiguration(for url: URL) -> BackingConfiguration? {
    let fileManager = FileManager()
    let fileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: url.path)
    guard
      let archiveFile = fopen(fileSystemRepresentation, "rb"),
      let (eocdRecord, zip64EOCD) = ZipArchive.scanForEndOfCentralDirectoryRecord(in: archiveFile) else
    {
      return nil
    }
    return BackingConfiguration(
      file: archiveFile,
      endOfCentralDirectoryRecord: eocdRecord,
      zip64EndOfCentralDirectory: zip64EOCD)
  }

  func makeIterator() -> AnyIterator<ZipEntry> {
    let totalNumberOfEntriesInCD = totalNumberOfEntriesInCentralDirectory
    var directoryIndex = offsetToStartOfCentralDirectory
    var index = 0
    return AnyIterator {
      guard index < totalNumberOfEntriesInCD else { return nil }
      guard
        let centralDirStruct: CentralDirectoryStructure = Data.readStruct(
          from: self.archiveFile,
          at: directoryIndex) else
      {
        return nil
      }
      let offset = UInt64(centralDirStruct.effectiveRelativeOffsetOfLocalHeader)
      guard
        let localFileHeader: LocalFileHeader = Data.readStruct(
          from: self.archiveFile,
          at: offset) else { return nil }
      var dataDescriptor: DataDescriptor?
      var zip64DataDescriptor: ZIP64DataDescriptor?
      if centralDirStruct.usesDataDescriptor {
        let additionalSize = UInt64(localFileHeader.fileNameLength) + UInt64(localFileHeader.extraFieldLength)
        let isCompressed = centralDirStruct.compressionMethod != 0
        let dataSize = isCompressed
          ? centralDirStruct.effectiveCompressedSize
          : centralDirStruct.effectiveUncompressedSize
        let descriptorPosition = offset + UInt64(LocalFileHeader.size) + additionalSize + dataSize
        if centralDirStruct.isZIP64 {
          zip64DataDescriptor = Data.readStruct(from: self.archiveFile, at: descriptorPosition)
        } else {
          dataDescriptor = Data.readStruct(from: self.archiveFile, at: descriptorPosition)
        }
      }
      defer {
        directoryIndex += UInt64(CentralDirectoryStructure.size)
        directoryIndex += UInt64(centralDirStruct.fileNameLength)
        directoryIndex += UInt64(centralDirStruct.extraFieldLength)
        directoryIndex += UInt64(centralDirStruct.fileCommentLength)
        index += 1
      }
      return ZipEntry(
        centralDirectoryStructure: centralDirStruct,
        localFileHeader: localFileHeader,
        dataDescriptor: dataDescriptor,
        zip64DataDescriptor: zip64DataDescriptor)
    }
  }

  /// Retrieve the ZIP `Entry` with the given `path` from the receiver.
  ///
  /// - Note: The ZIP file format specification does not enforce unique paths for entries.
  ///   Therefore an archive can contain multiple entries with the same path. This method
  ///   always returns the first `Entry` with the given `path`.
  ///
  /// - Parameter path: A relative file path identifying the corresponding `Entry`.
  /// - Returns: An `Entry` with the given `path`. Otherwise, `nil`.
  subscript(path: String) -> ZipEntry? {
    first { $0.path == path }
  }

  /// Read a ZIP `Entry` from the receiver and write it to `url`.
  ///
  /// - Parameters:
  ///   - entry: The ZIP `Entry` to read.
  ///   - url: The destination file URL.
  ///   - bufferSize: The maximum size of the read buffer and the decompression buffer (if needed).
  /// - Returns: The checksum of the processed content or 0 if the `skipCRC32` flag was set to `true`.
  /// - Throws: An error if the destination file cannot be written or the entry contains malformed content.
  func extract(_ entry: ZipEntry, to url: URL, bufferSize: Int = defaultReadChunkSize) throws -> UInt32 {
    guard bufferSize > 0 else { throw ArchiveError.invalidBufferSize }
    let fileManager = FileManager()
    try fileManager.createParentDirectoryStructure(for: url)
    let destinationRepresentation = fileManager.fileSystemRepresentation(withPath: url.path)
    guard let destinationFile: FILEPointer = fopen(destinationRepresentation, "wb+") else {
      throw CocoaError(.fileNoSuchFile)
    }
    defer { fclose(destinationFile) }

    guard bufferSize > 0 else { throw ArchiveError.invalidBufferSize }
    guard entry.dataOffset <= .max else { throw ArchiveError.invalidLocalHeaderDataOffset }
    fseeko(archiveFile, off_t(entry.dataOffset), SEEK_SET)

    let attributes = FileManager.attributes(from: entry)
    try fileManager.setAttributes(attributes, ofItemAtPath: url.path)

    let size = entry.centralDirectoryStructure.effectiveCompressedSize
    guard size <= .max else { throw ArchiveError.invalidEntrySize }
    return try Data.decompress(size: Int64(size), bufferSize: bufferSize, provider: { _, chunkSize -> Data in
      try Data.readChunk(of: chunkSize, from: self.archiveFile)
    }, consumer: { data in
      _ = try Data.write(chunk: data, to: destinationFile)
    })
  }

  // MARK: Private

  private static func scanForZIP64EndOfCentralDirectory(in file: FILEPointer, eocdOffset: UInt64)
    -> ZIP64EndOfCentralDirectory?
  {
    guard UInt64(ZIP64EndOfCentralDirectoryLocator.size) < eocdOffset else {
      return nil
    }
    let locatorOffset = eocdOffset - UInt64(ZIP64EndOfCentralDirectoryLocator.size)

    guard UInt64(ZIP64EndOfCentralDirectoryRecord.size) < locatorOffset else {
      return nil
    }
    let recordOffset = locatorOffset - UInt64(ZIP64EndOfCentralDirectoryRecord.size)
    guard
      let locator: ZIP64EndOfCentralDirectoryLocator = Data.readStruct(from: file, at: locatorOffset),
      let record: ZIP64EndOfCentralDirectoryRecord = Data.readStruct(from: file, at: recordOffset) else
    {
      return nil
    }
    return ZIP64EndOfCentralDirectory(record: record, locator: locator)
  }
}

// MARK: - Zip64

extension ZipArchive {

  struct ZIP64EndOfCentralDirectory {
    let record: ZIP64EndOfCentralDirectoryRecord
    let locator: ZIP64EndOfCentralDirectoryLocator
  }

  struct ZIP64EndOfCentralDirectoryRecord: DataSerializable {
    let zip64EOCDRecordSignature = UInt32(zip64EOCDRecordStructSignature)
    let sizeOfZIP64EndOfCentralDirectoryRecord: UInt64
    let versionMadeBy: UInt16
    let versionNeededToExtract: UInt16
    let numberOfDisk: UInt32
    let numberOfDiskStart: UInt32
    let totalNumberOfEntriesOnDisk: UInt64
    let totalNumberOfEntriesInCentralDirectory: UInt64
    let sizeOfCentralDirectory: UInt64
    let offsetToStartOfCentralDirectory: UInt64
    let zip64ExtensibleDataSector: Data
    static let size = 56
  }

  struct ZIP64EndOfCentralDirectoryLocator: DataSerializable {
    let zip64EOCDLocatorSignature = UInt32(zip64EOCDLocatorStructSignature)
    let numberOfDiskWithZIP64EOCDRecordStart: UInt32
    let relativeOffsetOfZIP64EOCDRecord: UInt64
    let totalNumberOfDisk: UInt32
    static let size = 20
  }

  static let zip64EOCDRecordStructSignature = 0x06064b50
  static let zip64EOCDLocatorStructSignature = 0x07064b50
}

extension ZipArchive.ZIP64EndOfCentralDirectoryRecord {

  // MARK: Lifecycle

  init?(data: Data, additionalDataProvider _: (Int) throws -> Data) {
    guard data.count == ZipArchive.ZIP64EndOfCentralDirectoryRecord.size else { return nil }
    guard data.scanValue(start: 0) == zip64EOCDRecordSignature else { return nil }
    sizeOfZIP64EndOfCentralDirectoryRecord = data.scanValue(start: 4)
    versionMadeBy = data.scanValue(start: 12)
    versionNeededToExtract = data.scanValue(start: 14)
    // Version Needed to Extract: 4.5 - File uses ZIP64 format extensions
    guard versionNeededToExtract >= 45 else { return nil }
    numberOfDisk = data.scanValue(start: 16)
    numberOfDiskStart = data.scanValue(start: 20)
    totalNumberOfEntriesOnDisk = data.scanValue(start: 24)
    totalNumberOfEntriesInCentralDirectory = data.scanValue(start: 32)
    sizeOfCentralDirectory = data.scanValue(start: 40)
    offsetToStartOfCentralDirectory = data.scanValue(start: 48)
    zip64ExtensibleDataSector = Data()
  }

  init(
    record: ZipArchive.ZIP64EndOfCentralDirectoryRecord,
    numberOfEntriesOnDisk: UInt64,
    numberOfEntriesInCD: UInt64,
    sizeOfCentralDirectory: UInt64,
    offsetToStartOfCD: UInt64)
  {
    sizeOfZIP64EndOfCentralDirectoryRecord = record.sizeOfZIP64EndOfCentralDirectoryRecord
    versionMadeBy = record.versionMadeBy
    versionNeededToExtract = record.versionNeededToExtract
    numberOfDisk = record.numberOfDisk
    numberOfDiskStart = record.numberOfDiskStart
    totalNumberOfEntriesOnDisk = numberOfEntriesOnDisk
    totalNumberOfEntriesInCentralDirectory = numberOfEntriesInCD
    self.sizeOfCentralDirectory = sizeOfCentralDirectory
    offsetToStartOfCentralDirectory = offsetToStartOfCD
    zip64ExtensibleDataSector = record.zip64ExtensibleDataSector
  }

  // MARK: Internal

  var data: Data {
    var zip64EOCDRecordSignature = zip64EOCDRecordSignature
    var sizeOfZIP64EOCDRecord = sizeOfZIP64EndOfCentralDirectoryRecord
    var versionMadeBy = versionMadeBy
    var versionNeededToExtract = versionNeededToExtract
    var numberOfDisk = numberOfDisk
    var numberOfDiskStart = numberOfDiskStart
    var totalNumberOfEntriesOnDisk = totalNumberOfEntriesOnDisk
    var totalNumberOfEntriesInCD = totalNumberOfEntriesInCentralDirectory
    var sizeOfCD = sizeOfCentralDirectory
    var offsetToStartOfCD = offsetToStartOfCentralDirectory
    var data = Data()
    withUnsafePointer(to: &zip64EOCDRecordSignature) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &sizeOfZIP64EOCDRecord) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &versionMadeBy) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &versionNeededToExtract) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &numberOfDisk) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &numberOfDiskStart) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &totalNumberOfEntriesOnDisk) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &totalNumberOfEntriesInCD) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &sizeOfCD) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &offsetToStartOfCD) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    data.append(zip64ExtensibleDataSector)
    return data
  }

}

extension ZipArchive.ZIP64EndOfCentralDirectoryLocator {

  // MARK: Lifecycle

  init?(data: Data, additionalDataProvider _: (Int) throws -> Data) {
    guard data.count == ZipArchive.ZIP64EndOfCentralDirectoryLocator.size else { return nil }
    guard data.scanValue(start: 0) == zip64EOCDLocatorSignature else { return nil }
    numberOfDiskWithZIP64EOCDRecordStart = data.scanValue(start: 4)
    relativeOffsetOfZIP64EOCDRecord = data.scanValue(start: 8)
    totalNumberOfDisk = data.scanValue(start: 16)
  }

  // MARK: Internal

  var data: Data {
    var zip64EOCDLocatorSignature = zip64EOCDLocatorSignature
    var numberOfDiskWithZIP64EOCD = numberOfDiskWithZIP64EOCDRecordStart
    var offsetOfZIP64EOCDRecord = relativeOffsetOfZIP64EOCDRecord
    var totalNumberOfDisk = totalNumberOfDisk
    var data = Data()
    withUnsafePointer(to: &zip64EOCDLocatorSignature) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &numberOfDiskWithZIP64EOCD) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &offsetOfZIP64EOCDRecord) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &totalNumberOfDisk) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    return data
  }

}

extension ZipArchive.EndOfCentralDirectoryRecord {

  // MARK: Lifecycle

  init?(data: Data, additionalDataProvider provider: (Int) throws -> Data) {
    guard data.count == ZipArchive.EndOfCentralDirectoryRecord.size else { return nil }
    guard data.scanValue(start: 0) == endOfCentralDirectorySignature else { return nil }
    numberOfDisk = data.scanValue(start: 4)
    numberOfDiskStart = data.scanValue(start: 6)
    totalNumberOfEntriesOnDisk = data.scanValue(start: 8)
    totalNumberOfEntriesInCentralDirectory = data.scanValue(start: 10)
    sizeOfCentralDirectory = data.scanValue(start: 12)
    offsetToStartOfCentralDirectory = data.scanValue(start: 16)
    zipFileCommentLength = data.scanValue(start: 20)
    guard let commentData = try? provider(Int(zipFileCommentLength)) else { return nil }
    guard commentData.count == Int(zipFileCommentLength) else { return nil }
    zipFileCommentData = commentData
  }

  // MARK: Internal

  var data: Data {
    var endOfCDSignature = endOfCentralDirectorySignature
    var numberOfDisk = numberOfDisk
    var numberOfDiskStart = numberOfDiskStart
    var totalNumberOfEntriesOnDisk = totalNumberOfEntriesOnDisk
    var totalNumberOfEntriesInCD = totalNumberOfEntriesInCentralDirectory
    var sizeOfCentralDirectory = sizeOfCentralDirectory
    var offsetToStartOfCD = offsetToStartOfCentralDirectory
    var zipFileCommentLength = zipFileCommentLength
    var data = Data()
    withUnsafePointer(to: &endOfCDSignature) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &numberOfDisk) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &numberOfDiskStart) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &totalNumberOfEntriesOnDisk) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &totalNumberOfEntriesInCD) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &sizeOfCentralDirectory) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &offsetToStartOfCD) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    withUnsafePointer(to: &zipFileCommentLength) { data.append(UnsafeBufferPointer(start: $0, count: 1)) }
    data.append(zipFileCommentData)
    return data
  }

}
