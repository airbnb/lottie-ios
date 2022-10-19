//
//  Entry.swift
//  ZIPFoundation
//
//  Copyright © 2017-2021 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
//  Released under the MIT License.
//
//  See https://github.com/weichsel/ZIPFoundation/blob/master/LICENSE for license information.
//

import Foundation
import CoreFoundation

/// A value that represents a file, a directory or a symbolic link within a ZIP `Archive`.
///
/// You can retrieve instances of `Entry` from an `Archive` via subscripting or iteration.
/// Entries are identified by their `path`.
public struct Entry: Equatable {
    /// The type of an `Entry` in a ZIP `Archive`.
    public enum EntryType: Int {
        /// Indicates a regular file.
        case file
        /// Indicates a directory.
        case directory
        /// Indicates a symbolic link.
        case symlink

        init(mode: mode_t) {
            switch mode & S_IFMT {
            case S_IFDIR:
                self = .directory
            case S_IFLNK:
                self = .symlink
            default:
                self = .file
            }
        }
    }

    enum OSType: UInt {
        case msdos = 0
        case unix = 3
        case osx = 19
        case unused = 20
    }

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
        static let size = 46
        let fileNameData: Data
        let extraFieldData: Data
        let fileCommentData: Data

        var extraFields: [ExtensibleDataField]?
        var usesDataDescriptor: Bool { return (self.generalPurposeBitFlag & (1 << 3 )) != 0 }
        var usesUTF8PathEncoding: Bool { return (self.generalPurposeBitFlag & (1 << 11 )) != 0 }
        var isEncrypted: Bool { return (self.generalPurposeBitFlag & (1 << 0)) != 0 }
        var isZIP64: Bool {
            // If ZIP64 extended information is existing, try to treat cd as ZIP64 format
            // even if the version needed to extract is lower than 4.5
            return UInt8(truncatingIfNeeded: self.versionNeededToExtract) >= 45 || zip64ExtendedInformation != nil
        }
    }
    /// Returns the `path` of the receiver within a ZIP `Archive` using a given encoding.
    ///
    /// - Parameters:
    ///   - encoding: `String.Encoding`
    public func path(using encoding: String.Encoding) -> String {
        return String(data: self.centralDirectoryStructure.fileNameData, encoding: encoding) ?? ""
    }
    /// The `path` of the receiver within a ZIP `Archive`.
    public var path: String {
        let dosLatinUS = 0x400
        let dosLatinUSEncoding = CFStringEncoding(dosLatinUS)
        let dosLatinUSStringEncoding = CFStringConvertEncodingToNSStringEncoding(dosLatinUSEncoding)
        let codepage437 = String.Encoding(rawValue: dosLatinUSStringEncoding)
        let encoding = self.centralDirectoryStructure.usesUTF8PathEncoding ? .utf8 : codepage437
        return self.path(using: encoding)
    }
    /// The file attributes of the receiver as key/value pairs.
    ///
    /// Contains the modification date and file permissions.
    public var fileAttributes: [FileAttributeKey: Any] {
        return FileManager.attributes(from: self)
    }
    /// The `CRC32` checksum of the receiver.
    ///
    /// - Note: Always returns `0` for entries of type `EntryType.directory`.
    public var checksum: CRC32 {
        if self.centralDirectoryStructure.usesDataDescriptor {
            return self.zip64DataDescriptor?.crc32 ?? self.dataDescriptor?.crc32 ?? 0
        }
        return self.centralDirectoryStructure.crc32
    }
    /// The `EntryType` of the receiver.
    public var type: EntryType {
        // OS Type is stored in the upper byte of versionMadeBy
        let osTypeRaw = self.centralDirectoryStructure.versionMadeBy >> 8
        let osType = OSType(rawValue: UInt(osTypeRaw)) ?? .unused
        var isDirectory = self.path.hasSuffix("/")
        switch osType {
        case .unix, .osx:
            let mode = mode_t(self.centralDirectoryStructure.externalFileAttributes >> 16) & S_IFMT
            switch mode {
            case S_IFREG:
                return .file
            case S_IFDIR:
                return .directory
            case S_IFLNK:
                return .symlink
            default:
                return isDirectory ? .directory : .file
            }
        case .msdos:
            isDirectory = isDirectory || ((centralDirectoryStructure.externalFileAttributes >> 4) == 0x01)
            fallthrough // For all other OSes we can only guess based on the directory suffix char
        default: return isDirectory ? .directory : .file
        }
    }
    /// Indicates whether or not the receiver is compressed.
    public var isCompressed: Bool {
        self.localFileHeader.compressionMethod != CompressionMethod.none.rawValue
    }
    /// The size of the receiver's compressed data.
    public var compressedSize: UInt64 {
        if centralDirectoryStructure.isZIP64 {
            return zip64DataDescriptor?.compressedSize ?? centralDirectoryStructure.effectiveCompressedSize
        }
        return UInt64(dataDescriptor?.compressedSize ?? centralDirectoryStructure.compressedSize)
    }
    /// The size of the receiver's uncompressed data.
    public var uncompressedSize: UInt64 {
        if centralDirectoryStructure.isZIP64 {
            return zip64DataDescriptor?.uncompressedSize ?? centralDirectoryStructure.effectiveUncompressedSize
        }
        return UInt64(dataDescriptor?.uncompressedSize ?? centralDirectoryStructure.uncompressedSize)
    }
    /// The combined size of the local header, the data and the optional data descriptor.
    var localSize: UInt64 {
        let localFileHeader = self.localFileHeader
        var extraDataLength = Int(localFileHeader.fileNameLength)
        extraDataLength += Int(localFileHeader.extraFieldLength)
        var size = UInt64(LocalFileHeader.size + extraDataLength)
        size += self.isCompressed ? self.compressedSize : self.uncompressedSize
        if centralDirectoryStructure.isZIP64 {
            size += self.zip64DataDescriptor != nil ? UInt64(ZIP64DataDescriptor.size) : 0
        } else {
            size += self.dataDescriptor != nil ? UInt64(DefaultDataDescriptor.size) : 0
        }
        return size
    }
    var dataOffset: UInt64 {
        var dataOffset = self.centralDirectoryStructure.effectiveRelativeOffsetOfLocalHeader
        dataOffset += UInt64(LocalFileHeader.size)
        dataOffset += UInt64(self.localFileHeader.fileNameLength)
        dataOffset += UInt64(self.localFileHeader.extraFieldLength)
        return dataOffset
    }
    let centralDirectoryStructure: CentralDirectoryStructure
    let localFileHeader: LocalFileHeader
    let dataDescriptor: DefaultDataDescriptor?
    let zip64DataDescriptor: ZIP64DataDescriptor?

    public static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.path == rhs.path
            && lhs.localFileHeader.crc32 == rhs.localFileHeader.crc32
            && lhs.centralDirectoryStructure.effectiveRelativeOffsetOfLocalHeader
            == rhs.centralDirectoryStructure.effectiveRelativeOffsetOfLocalHeader
    }

    init?(centralDirectoryStructure: CentralDirectoryStructure,
          localFileHeader: LocalFileHeader,
          dataDescriptor: DefaultDataDescriptor? = nil,
          zip64DataDescriptor: ZIP64DataDescriptor? = nil) {
        // We currently don't support encrypted archives
        guard !centralDirectoryStructure.isEncrypted else { return nil }
        self.centralDirectoryStructure = centralDirectoryStructure
        self.localFileHeader = localFileHeader
        self.dataDescriptor = dataDescriptor
        self.zip64DataDescriptor = zip64DataDescriptor
    }
}

extension Entry.CentralDirectoryStructure {

    init(localFileHeader: Entry.LocalFileHeader, fileAttributes: UInt32, relativeOffset: UInt32,
         extraField: (length: UInt16, data: Data)) {
        self.versionMadeBy = UInt16(789)
        self.versionNeededToExtract = localFileHeader.versionNeededToExtract
        self.generalPurposeBitFlag = localFileHeader.generalPurposeBitFlag
        self.compressionMethod = localFileHeader.compressionMethod
        self.lastModFileTime = localFileHeader.lastModFileTime
        self.lastModFileDate = localFileHeader.lastModFileDate
        self.crc32 = localFileHeader.crc32
        self.compressedSize = localFileHeader.compressedSize
        self.uncompressedSize = localFileHeader.uncompressedSize
        self.fileNameLength = localFileHeader.fileNameLength
        self.extraFieldLength = extraField.length
        self.fileCommentLength = UInt16(0)
        self.diskNumberStart = UInt16(0)
        self.internalFileAttributes = UInt16(0)
        self.externalFileAttributes = fileAttributes
        self.relativeOffsetOfLocalHeader = relativeOffset
        self.fileNameData = localFileHeader.fileNameData
        self.extraFieldData = extraField.data
        self.fileCommentData = Data()
        if let zip64ExtendedInformation = Entry.ZIP64ExtendedInformation.scanForZIP64Field(in: self.extraFieldData,
                                                                                           fields: self.validFields) {
            self.extraFields = [zip64ExtendedInformation]
        }
    }

    init(centralDirectoryStructure: Entry.CentralDirectoryStructure,
         zip64ExtendedInformation: Entry.ZIP64ExtendedInformation?, relativeOffset: UInt32) {
        if let existingInfo = zip64ExtendedInformation {
            self.extraFieldData = existingInfo.data
            self.versionNeededToExtract = max(centralDirectoryStructure.versionNeededToExtract,
                                              Archive.Version.v45.rawValue)
        } else {
            self.extraFieldData = centralDirectoryStructure.extraFieldData
            let existingVersion = centralDirectoryStructure.versionNeededToExtract
            self.versionNeededToExtract = existingVersion < Archive.Version.v45.rawValue
                ? centralDirectoryStructure.versionNeededToExtract
                : Archive.Version.v20.rawValue
        }
        self.extraFieldLength = UInt16(extraFieldData.count)
        self.relativeOffsetOfLocalHeader = relativeOffset
        self.versionMadeBy = centralDirectoryStructure.versionMadeBy
        self.generalPurposeBitFlag = centralDirectoryStructure.generalPurposeBitFlag
        self.compressionMethod = centralDirectoryStructure.compressionMethod
        self.lastModFileTime = centralDirectoryStructure.lastModFileTime
        self.lastModFileDate = centralDirectoryStructure.lastModFileDate
        self.crc32 = centralDirectoryStructure.crc32
        self.compressedSize = centralDirectoryStructure.compressedSize
        self.uncompressedSize = centralDirectoryStructure.uncompressedSize
        self.fileNameLength = centralDirectoryStructure.fileNameLength
        self.fileCommentLength = centralDirectoryStructure.fileCommentLength
        self.diskNumberStart = centralDirectoryStructure.diskNumberStart
        self.internalFileAttributes = centralDirectoryStructure.internalFileAttributes
        self.externalFileAttributes = centralDirectoryStructure.externalFileAttributes
        self.fileNameData = centralDirectoryStructure.fileNameData
        self.fileCommentData = centralDirectoryStructure.fileCommentData
        if let zip64ExtendedInformation = Entry.ZIP64ExtendedInformation.scanForZIP64Field(in: self.extraFieldData,
                                                                                           fields: self.validFields) {
            self.extraFields = [zip64ExtendedInformation]
        }
    }
}

extension Entry.CentralDirectoryStructure {

    var effectiveCompressedSize: UInt64 {
        if self.isZIP64, let compressedSize = self.zip64ExtendedInformation?.compressedSize, compressedSize > 0 {
            return compressedSize
        }
        return UInt64(compressedSize)
    }
    var effectiveUncompressedSize: UInt64 {
        if self.isZIP64, let uncompressedSize = self.zip64ExtendedInformation?.uncompressedSize, uncompressedSize > 0 {
            return uncompressedSize
        }
        return UInt64(uncompressedSize)
    }
    var effectiveRelativeOffsetOfLocalHeader: UInt64 {
        if self.isZIP64, let offset = self.zip64ExtendedInformation?.relativeOffsetOfLocalHeader, offset > 0 {
            return offset
        }
        return UInt64(relativeOffsetOfLocalHeader)
    }
}
