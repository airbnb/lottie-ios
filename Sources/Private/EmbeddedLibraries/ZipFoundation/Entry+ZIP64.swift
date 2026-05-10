//
//  Entry+ZIP64.swift
//  ZIPFoundation
//
//  Copyright © 2017-2025 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
//  Released under the MIT License.
//
//  See https://github.com/weichsel/ZIPFoundation/blob/master/LICENSE for license information.
//

import Foundation

protocol ExtensibleDataField {
    var headerID: UInt16 { get }
    var dataSize: UInt16 { get }
}

extension Entry {

    enum EntryError: Error {
        case missingPermissionsAttributeError
        case missingModificationDateAttributeError
    }

    struct ZIP64ExtendedInformation: ExtensibleDataField {
        let headerID: UInt16 = ExtraFieldHeaderID.zip64ExtendedInformation.rawValue
        let dataSize: UInt16
        static let headerSize: UInt16 = 4
        let uncompressedSize: UInt64
        let compressedSize: UInt64
        let relativeOffsetOfLocalHeader: UInt64
        let diskNumberStart: UInt32
    }

    var zip64ExtendedInformation: ZIP64ExtendedInformation? {
        self.centralDirectoryStructure.zip64ExtendedInformation
    }
}

typealias Field = Entry.ZIP64ExtendedInformation.Field

extension Entry.LocalFileHeader {
    var validFields: [Field] {
        var fields: [Field] = []
        if self.uncompressedSize == .max { fields.append(.uncompressedSize) }
        if self.compressedSize == .max { fields.append(.compressedSize) }
        return fields
    }
}

extension Entry.CentralDirectoryStructure {
    var validFields: [Field] {
        var fields: [Field] = []
        if self.uncompressedSize == .max { fields.append(.uncompressedSize) }
        if self.compressedSize == .max { fields.append(.compressedSize) }
        if self.relativeOffsetOfLocalHeader == .max { fields.append(.relativeOffsetOfLocalHeader) }
        if self.diskNumberStart == .max { fields.append(.diskNumberStart) }
        return fields
    }
    var zip64ExtendedInformation: Entry.ZIP64ExtendedInformation? {
        self.extraFields?.compactMap { $0 as? Entry.ZIP64ExtendedInformation }.first
    }
}

extension Entry.ZIP64ExtendedInformation {

    enum Field {
        case uncompressedSize
        case compressedSize
        case relativeOffsetOfLocalHeader
        case diskNumberStart

        var size: Int {
            switch self {
            case .uncompressedSize, .compressedSize, .relativeOffsetOfLocalHeader:
                return 8
            case .diskNumberStart:
                return 4
            }
        }
    }

    var data: Data {
        var headerID = self.headerID
        var dataSize = self.dataSize
        var uncompressedSize = self.uncompressedSize
        var compressedSize = self.compressedSize
        var relativeOffsetOfLFH = self.relativeOffsetOfLocalHeader
        var diskNumberStart = self.diskNumberStart
        var data = Data()
        withUnsafePointer(to: &headerID, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &dataSize, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        if uncompressedSize != 0 || compressedSize != 0 {
            withUnsafePointer(to: &uncompressedSize, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
            withUnsafePointer(to: &compressedSize, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        }
        if relativeOffsetOfLocalHeader != 0 {
            withUnsafePointer(to: &relativeOffsetOfLFH, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        }
        if diskNumberStart != 0 {
            withUnsafePointer(to: &diskNumberStart, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        }
        return data
    }

    init?(data: Data, fields: [Field]) {
        let headerLength = 4
        guard fields.reduce(0, { $0 + $1.size }) + headerLength == data.count else { return nil }

        var readOffset = headerLength
        func value<T>(of field: Field) -> T where T: BinaryInteger {
            if fields.contains(field), readOffset + field.size <= data.count {
                defer { readOffset += MemoryLayout<T>.size }

                return data.scanValue(start: readOffset)
            } else {
                return 0
            }
        }

        self.dataSize = data.scanValue(start: 2)
        self.uncompressedSize = value(of: .uncompressedSize)
        self.compressedSize = value(of: .compressedSize)
        self.relativeOffsetOfLocalHeader = value(of: .relativeOffsetOfLocalHeader)
        self.diskNumberStart = value(of: .diskNumberStart)
    }

    init?(zip64ExtendedInformation: Entry.ZIP64ExtendedInformation?, offset: UInt64) {
        // Only used when removing entry, if no ZIP64 extended information exists,
        // then this information will not be newly added either
        guard let existingInfo = zip64ExtendedInformation else { return nil }
        relativeOffsetOfLocalHeader = offset >= maxOffsetOfLocalFileHeader ? offset : 0
        uncompressedSize = existingInfo.uncompressedSize
        compressedSize = existingInfo.compressedSize
        diskNumberStart = existingInfo.diskNumberStart
        let tempDataSize = [relativeOffsetOfLocalHeader, uncompressedSize, compressedSize]
            .filter { $0 != 0 }
            .reduce(UInt16(0), { $0 + UInt16(MemoryLayout.size(ofValue: $1))})
        dataSize = tempDataSize + (diskNumberStart > 0 ? UInt16(MemoryLayout.size(ofValue: diskNumberStart)) : 0)
        if dataSize == 0 { return nil }
    }

    static func scanForZIP64Field(in data: Data, fields: [Field]) -> Entry.ZIP64ExtendedInformation? {
        guard data.isEmpty == false else { return nil }
        var offset = 0
        var headerID: UInt16
        var dataSize: UInt16
        let extraFieldLength = data.count
        let headerSize = Int(Entry.ZIP64ExtendedInformation.headerSize)
        while offset < extraFieldLength - headerSize {
            headerID = data.scanValue(start: offset)
            dataSize = data.scanValue(start: offset + 2)
            let nextOffset = offset + headerSize + Int(dataSize)
            guard nextOffset <= extraFieldLength else { return nil }
            if headerID == ExtraFieldHeaderID.zip64ExtendedInformation.rawValue {
                return Entry.ZIP64ExtendedInformation(data: data.subdata(in: offset..<nextOffset), fields: fields)
            }
            offset = nextOffset
        }
        return nil
    }
}
