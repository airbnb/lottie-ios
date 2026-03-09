//
//  Entry+Serialization.swift
//  ZIPFoundation
//
//  Copyright © 2017-2024 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
//  Released under the MIT License.
//
//  See https://github.com/weichsel/ZIPFoundation/blob/master/LICENSE for license information.
//

import Foundation

extension Entry.LocalFileHeader {
    var data: Data {
        var localFileHeaderSignature = self.localFileHeaderSignature
        var versionNeededToExtract = self.versionNeededToExtract
        var generalPurposeBitFlag = self.generalPurposeBitFlag
        var compressionMethod = self.compressionMethod
        var lastModFileTime = self.lastModFileTime
        var lastModFileDate = self.lastModFileDate
        var crc32 = self.crc32
        var compressedSize = self.compressedSize
        var uncompressedSize = self.uncompressedSize
        var fileNameLength = self.fileNameLength
        var extraFieldLength = self.extraFieldLength
        var data = Data()
        withUnsafePointer(to: &localFileHeaderSignature, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &versionNeededToExtract, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &generalPurposeBitFlag, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &compressionMethod, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &lastModFileTime, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &lastModFileDate, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &crc32, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &compressedSize, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &uncompressedSize, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &fileNameLength, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &extraFieldLength, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        data.append(self.fileNameData)
        data.append(self.extraFieldData)
        return data
    }

    init?(data: Data, additionalDataProvider provider: (Int) throws -> Data) {
        guard data.count == Entry.LocalFileHeader.size else { return nil }
        guard data.scanValue(start: 0) == localFileHeaderSignature else { return nil }
        self.versionNeededToExtract = data.scanValue(start: 4)
        self.generalPurposeBitFlag = data.scanValue(start: 6)
        self.compressionMethod = data.scanValue(start: 8)
        self.lastModFileTime = data.scanValue(start: 10)
        self.lastModFileDate = data.scanValue(start: 12)
        self.crc32 = data.scanValue(start: 14)
        self.compressedSize = data.scanValue(start: 18)
        self.uncompressedSize = data.scanValue(start: 22)
        self.fileNameLength = data.scanValue(start: 26)
        self.extraFieldLength = data.scanValue(start: 28)
        let additionalDataLength = Int(self.fileNameLength) + Int(self.extraFieldLength)
        guard let additionalData = try? provider(additionalDataLength) else { return nil }
        guard additionalData.count == additionalDataLength else { return nil }
        var subRangeStart = 0
        var subRangeEnd = Int(self.fileNameLength)
        self.fileNameData = additionalData.subdata(in: subRangeStart..<subRangeEnd)
        subRangeStart += Int(self.fileNameLength)
        subRangeEnd = subRangeStart + Int(self.extraFieldLength)
        self.extraFieldData = additionalData.subdata(in: subRangeStart..<subRangeEnd)
        if let zip64ExtendedInformation = Entry.ZIP64ExtendedInformation.scanForZIP64Field(in: self.extraFieldData,
                                                                                           fields: self.validFields) {
            self.extraFields = [zip64ExtendedInformation]
        }
    }
}

extension Entry.CentralDirectoryStructure {
    var data: Data {
        var centralDirectorySignature = self.centralDirectorySignature
        var versionMadeBy = self.versionMadeBy
        var versionNeededToExtract = self.versionNeededToExtract
        var generalPurposeBitFlag = self.generalPurposeBitFlag
        var compressionMethod = self.compressionMethod
        var lastModFileTime = self.lastModFileTime
        var lastModFileDate = self.lastModFileDate
        var crc32 = self.crc32
        var compressedSize = self.compressedSize
        var uncompressedSize = self.uncompressedSize
        var fileNameLength = self.fileNameLength
        var extraFieldLength = self.extraFieldLength
        var fileCommentLength = self.fileCommentLength
        var diskNumberStart = self.diskNumberStart
        var internalFileAttributes = self.internalFileAttributes
        var externalFileAttributes = self.externalFileAttributes
        var relativeOffsetOfLocalHeader = self.relativeOffsetOfLocalHeader
        var data = Data()
        withUnsafePointer(to: &centralDirectorySignature, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &versionMadeBy, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &versionNeededToExtract, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &generalPurposeBitFlag, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &compressionMethod, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &lastModFileTime, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &lastModFileDate, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &crc32, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &compressedSize, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &uncompressedSize, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &fileNameLength, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &extraFieldLength, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &fileCommentLength, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &diskNumberStart, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &internalFileAttributes, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &externalFileAttributes, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &relativeOffsetOfLocalHeader, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        data.append(self.fileNameData)
        data.append(self.extraFieldData)
        data.append(self.fileCommentData)
        return data
    }

    init?(data: Data, additionalDataProvider provider: (Int) throws -> Data) {
        guard data.count == Entry.CentralDirectoryStructure.size else { return nil }
        guard data.scanValue(start: 0) == centralDirectorySignature else { return nil }
        self.versionMadeBy = data.scanValue(start: 4)
        self.versionNeededToExtract = data.scanValue(start: 6)
        self.generalPurposeBitFlag = data.scanValue(start: 8)
        self.compressionMethod = data.scanValue(start: 10)
        self.lastModFileTime = data.scanValue(start: 12)
        self.lastModFileDate = data.scanValue(start: 14)
        self.crc32 = data.scanValue(start: 16)
        self.compressedSize = data.scanValue(start: 20)
        self.uncompressedSize = data.scanValue(start: 24)
        self.fileNameLength = data.scanValue(start: 28)
        self.extraFieldLength = data.scanValue(start: 30)
        self.fileCommentLength = data.scanValue(start: 32)
        self.diskNumberStart = data.scanValue(start: 34)
        self.internalFileAttributes = data.scanValue(start: 36)
        self.externalFileAttributes = data.scanValue(start: 38)
        self.relativeOffsetOfLocalHeader = data.scanValue(start: 42)
        let additionalDataLength = Int(self.fileNameLength) + Int(self.extraFieldLength) + Int(self.fileCommentLength)
        guard let additionalData = try? provider(additionalDataLength) else { return nil }
        guard additionalData.count == additionalDataLength else { return nil }
        var subRangeStart = 0
        var subRangeEnd = Int(self.fileNameLength)
        self.fileNameData = additionalData.subdata(in: subRangeStart..<subRangeEnd)
        subRangeStart += Int(self.fileNameLength)
        subRangeEnd = subRangeStart + Int(self.extraFieldLength)
        self.extraFieldData = additionalData.subdata(in: subRangeStart..<subRangeEnd)
        subRangeStart += Int(self.extraFieldLength)
        subRangeEnd = subRangeStart + Int(self.fileCommentLength)
        self.fileCommentData = additionalData.subdata(in: subRangeStart..<subRangeEnd)
        if let zip64ExtendedInformation = Entry.ZIP64ExtendedInformation.scanForZIP64Field(in: self.extraFieldData,
                                                                                           fields: self.validFields) {
            self.extraFields = [zip64ExtendedInformation]
        }
    }
}

extension Entry.DataDescriptor {
    init?(data: Data, additionalDataProvider provider: (Int) throws -> Data) {
        guard data.count == Self.size else { return nil }
        let signature: UInt32 = data.scanValue(start: 0)
        // The DataDescriptor signature is not mandatory so we have to re-arrange the input data if it is missing.
        var readOffset = 0
        if signature == self.dataDescriptorSignature { readOffset = 4 }
        self.crc32 = data.scanValue(start: readOffset)
        readOffset += MemoryLayout<UInt32>.size
        self.compressedSize = data.scanValue(start: readOffset)
        readOffset += Self.memoryLengthOfSize
        self.uncompressedSize = data.scanValue(start: readOffset)
        // Our add(_ entry:) methods always maintain compressed & uncompressed
        // sizes and so we don't need a data descriptor for newly added entries.
        // Data descriptors of already existing entries are manually preserved
        // when copying those entries to the tempArchive during remove(_ entry:).
        self.data = Data()
    }
}
