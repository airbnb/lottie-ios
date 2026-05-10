//
//  Entry.swift
//  ZIPFoundation
//
//  Copyright © 2017-2025 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
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
struct Entry: Equatable {
    /// The type of an `Entry` in a ZIP `Archive`.
    enum EntryType: Int {
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
    func path(using encoding: String.Encoding) -> String {
        return String(pathData: self.centralDirectoryStructure.fileNameData, encoding: encoding)
    }
    /// The `path` of the receiver within a ZIP `Archive`.
    var path: String {
        let encoding = self.centralDirectoryStructure.usesUTF8PathEncoding ? String.Encoding.utf8 : .codepage437
        return self.path(using: encoding)
    }
    /// The file attributes of the receiver as key/value pairs.
    ///
    /// Contains the modification date and file permissions.
    var fileAttributes: [FileAttributeKey: Any] {
        return FileManager.attributes(from: self)
    }
    /// The `CRC32` checksum of the receiver.
    ///
    /// - Note: Always returns `0` for entries of type `EntryType.directory`.
    var checksum: CRC32 {
        if self.centralDirectoryStructure.usesDataDescriptor {
            return self.zip64DataDescriptor?.crc32 ?? self.dataDescriptor?.crc32 ?? 0
        }
        return self.centralDirectoryStructure.crc32
    }
    /// The `EntryType` of the receiver.
    var type: EntryType {
        // OS Type is stored in the upper byte of versionMadeBy
        let osTypeRaw = self.centralDirectoryStructure.versionMadeBy >> 8
        let osType = OSType(rawValue: UInt(osTypeRaw)) ?? .unused
        var isDirectory = self.path.hasSuffix("/")
        switch osType {
        case .unix, .osx:
            // Use truncatingIfNeeded for safer conversion across platforms
            let modeValue = UInt16(truncatingIfNeeded: self.centralDirectoryStructure.externalFileAttributes >> 16)
            let mode = mode_t(modeValue) & S_IFMT
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
    var isCompressed: Bool {
        self.localFileHeader.compressionMethod != CompressionMethod.none.rawValue
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

    static func == (lhs: Entry, rhs: Entry) -> Bool {
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

extension String.Encoding {

    static let codepage437: Self = {
        let dosLatinUS = 0x400
        let dosLatinUSEncoding = CFStringEncoding(dosLatinUS)
        let dosLatinUSStringEncoding = CFStringConvertEncodingToNSStringEncoding(dosLatinUSEncoding)
        return String.Encoding(rawValue: dosLatinUSStringEncoding)
    }()
}

extension String {

    init(pathData: Data, encoding: String.Encoding) {
        #if os(Linux)
        if encoding == .codepage437 {
            self.init()
            for byte in pathData {
                self.unicodeScalars.append(Self.cp437Lookup[Int(byte)])
            }
            return
        }
        #endif
        self = String(data: pathData, encoding: encoding) ?? ""
    }

    #if os(Linux)
    // Source: https://en.wikipedia.org/wiki/Code_page_437#Character_set
    private static let cp437Lookup: [UnicodeScalar] = [
        0x0000, 0x263A, 0x263B, 0x2665, 0x2666, 0x2663, 0x2660, 0x2022,
        0x25D8, 0x25CB, 0x25D9, 0x2642, 0x2640, 0x266A, 0x266B, 0x263C,
        0x25BA, 0x25C4, 0x2195, 0x203C, 0x00B6, 0x00A7, 0x25AC, 0x21A8,
        0x2191, 0x2193, 0x2192, 0x2190, 0x221F, 0x2194, 0x25B2, 0x25BC,
        0x0020, 0x0021, 0x0022, 0x0023, 0x0024, 0x0025, 0x0026, 0x0027,
        0x0028, 0x0029, 0x002A, 0x002B, 0x002C, 0x002D, 0x002E, 0x002F,
        0x0030, 0x0031, 0x0032, 0x0033, 0x0034, 0x0035, 0x0036, 0x0037,
        0x0038, 0x0039, 0x003A, 0x003B, 0x003C, 0x003D, 0x003E, 0x003F,
        0x0040, 0x0041, 0x0042, 0x0043, 0x0044, 0x0045, 0x0046, 0x0047,
        0x0048, 0x0049, 0x004A, 0x004B, 0x004C, 0x004D, 0x004E, 0x004F,
        0x0050, 0x0051, 0x0052, 0x0053, 0x0054, 0x0055, 0x0056, 0x0057,
        0x0058, 0x0059, 0x005A, 0x005B, 0x005C, 0x005D, 0x005E, 0x005F,
        0x0060, 0x0061, 0x0062, 0x0063, 0x0064, 0x0065, 0x0066, 0x0067,
        0x0068, 0x0069, 0x006A, 0x006B, 0x006C, 0x006D, 0x006E, 0x006F,
        0x0070, 0x0071, 0x0072, 0x0073, 0x0074, 0x0075, 0x0076, 0x0077,
        0x0078, 0x0079, 0x007A, 0x007B, 0x007C, 0x007D, 0x007E, 0x2302,
        0x00C7, 0x00FC, 0x00E9, 0x00E2, 0x00E4, 0x00E0, 0x00E5, 0x00E7,
        0x00EA, 0x00EB, 0x00E8, 0x00EF, 0x00EE, 0x00EC, 0x00C4, 0x00C5,
        0x00C9, 0x00E6, 0x00C6, 0x00F4, 0x00F6, 0x00F2, 0x00FB, 0x00F9,
        0x00FF, 0x00D6, 0x00DC, 0x00A2, 0x00A3, 0x00A5, 0x20A7, 0x0192,
        0x00E1, 0x00ED, 0x00F3, 0x00FA, 0x00F1, 0x00D1, 0x00AA, 0x00BA,
        0x00BF, 0x2310, 0x00AC, 0x00BD, 0x00BC, 0x00A1, 0x00AB, 0x00BB,
        0x2591, 0x2592, 0x2593, 0x2502, 0x2524, 0x2561, 0x2562, 0x2556,
        0x2555, 0x2563, 0x2551, 0x2557, 0x255D, 0x255C, 0x255B, 0x2510,
        0x2514, 0x2534, 0x252C, 0x251C, 0x2500, 0x253C, 0x255E, 0x255F,
        0x255A, 0x2554, 0x2569, 0x2566, 0x2560, 0x2550, 0x256C, 0x2567,
        0x2568, 0x2564, 0x2565, 0x2559, 0x2558, 0x2552, 0x2553, 0x256B,
        0x256A, 0x2518, 0x250C, 0x2588, 0x2584, 0x258C, 0x2590, 0x2580,
        0x03B1, 0x00DF, 0x0393, 0x03C0, 0x03A3, 0x03C3, 0x00B5, 0x03C4,
        0x03A6, 0x0398, 0x03A9, 0x03B4, 0x221E, 0x03C6, 0x03B5, 0x2229,
        0x2261, 0x00B1, 0x2265, 0x2264, 0x2329, 0x2321, 0x00F7, 0x2248,
        0x00B0, 0x2219, 0x00B7, 0x221A, 0x207F, 0x00B2, 0x25A0, 0x00A0
    ].map { UnicodeScalar($0)! }
    #endif

}
