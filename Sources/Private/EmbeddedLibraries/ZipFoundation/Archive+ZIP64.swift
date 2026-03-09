//
//  Archive+ZIP64.swift
//  ZIPFoundation
//
//  Copyright © 2017-2024 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
//  Released under the MIT License.
//
//  See https://github.com/weichsel/ZIPFoundation/blob/master/LICENSE for license information.
//

import Foundation

let zip64EOCDRecordStructSignature = 0x06064b50
let zip64EOCDLocatorStructSignature = 0x07064b50

enum ExtraFieldHeaderID: UInt16 {
    case zip64ExtendedInformation = 0x0001
}

extension Archive {
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
}

extension Archive.ZIP64EndOfCentralDirectoryRecord {
    var data: Data {
        var zip64EOCDRecordSignature = self.zip64EOCDRecordSignature
        var sizeOfZIP64EOCDRecord = self.sizeOfZIP64EndOfCentralDirectoryRecord
        var versionMadeBy = self.versionMadeBy
        var versionNeededToExtract = self.versionNeededToExtract
        var numberOfDisk = self.numberOfDisk
        var numberOfDiskStart = self.numberOfDiskStart
        var totalNumberOfEntriesOnDisk = self.totalNumberOfEntriesOnDisk
        var totalNumberOfEntriesInCD = self.totalNumberOfEntriesInCentralDirectory
        var sizeOfCD = self.sizeOfCentralDirectory
        var offsetToStartOfCD = self.offsetToStartOfCentralDirectory
        var data = Data()
        withUnsafePointer(to: &zip64EOCDRecordSignature, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &sizeOfZIP64EOCDRecord, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &versionMadeBy, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &versionNeededToExtract, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &numberOfDisk, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &numberOfDiskStart, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &totalNumberOfEntriesOnDisk, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &totalNumberOfEntriesInCD, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &sizeOfCD, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &offsetToStartOfCD, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        data.append(self.zip64ExtensibleDataSector)
        return data
    }

    init?(data: Data, additionalDataProvider provider: (Int) throws -> Data) {
        guard data.count == Archive.ZIP64EndOfCentralDirectoryRecord.size else { return nil }
        guard data.scanValue(start: 0) == zip64EOCDRecordSignature else { return nil }
        self.sizeOfZIP64EndOfCentralDirectoryRecord = data.scanValue(start: 4)
        self.versionMadeBy = data.scanValue(start: 12)
        self.versionNeededToExtract = data.scanValue(start: 14)
        // Version Needed to Extract: 4.5 - File uses ZIP64 format extensions
        guard self.versionNeededToExtract >= Archive.Version.v45.rawValue else { return nil }
        self.numberOfDisk = data.scanValue(start: 16)
        self.numberOfDiskStart = data.scanValue(start: 20)
        self.totalNumberOfEntriesOnDisk = data.scanValue(start: 24)
        self.totalNumberOfEntriesInCentralDirectory = data.scanValue(start: 32)
        self.sizeOfCentralDirectory = data.scanValue(start: 40)
        self.offsetToStartOfCentralDirectory = data.scanValue(start: 48)
        self.zip64ExtensibleDataSector = Data()
    }

    init(record: Archive.ZIP64EndOfCentralDirectoryRecord,
         numberOfEntriesOnDisk: UInt64,
         numberOfEntriesInCD: UInt64,
         sizeOfCentralDirectory: UInt64,
         offsetToStartOfCD: UInt64) {
        self.sizeOfZIP64EndOfCentralDirectoryRecord = record.sizeOfZIP64EndOfCentralDirectoryRecord
        self.versionMadeBy = record.versionMadeBy
        self.versionNeededToExtract = record.versionNeededToExtract
        self.numberOfDisk = record.numberOfDisk
        self.numberOfDiskStart = record.numberOfDiskStart
        self.totalNumberOfEntriesOnDisk = numberOfEntriesOnDisk
        self.totalNumberOfEntriesInCentralDirectory = numberOfEntriesInCD
        self.sizeOfCentralDirectory = sizeOfCentralDirectory
        self.offsetToStartOfCentralDirectory = offsetToStartOfCD
        self.zip64ExtensibleDataSector = record.zip64ExtensibleDataSector
    }
}

extension Archive.ZIP64EndOfCentralDirectoryLocator {
    var data: Data {
        var zip64EOCDLocatorSignature = self.zip64EOCDLocatorSignature
        var numberOfDiskWithZIP64EOCD = self.numberOfDiskWithZIP64EOCDRecordStart
        var offsetOfZIP64EOCDRecord = self.relativeOffsetOfZIP64EOCDRecord
        var totalNumberOfDisk = self.totalNumberOfDisk
        var data = Data()
        withUnsafePointer(to: &zip64EOCDLocatorSignature, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &numberOfDiskWithZIP64EOCD, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &offsetOfZIP64EOCDRecord, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        withUnsafePointer(to: &totalNumberOfDisk, { data.append(UnsafeBufferPointer(start: $0, count: 1))})
        return data
    }

    init?(data: Data, additionalDataProvider provider: (Int) throws -> Data) {
        guard data.count == Archive.ZIP64EndOfCentralDirectoryLocator.size else { return nil }
        guard data.scanValue(start: 0) == zip64EOCDLocatorSignature else { return nil }
        self.numberOfDiskWithZIP64EOCDRecordStart = data.scanValue(start: 4)
        self.relativeOffsetOfZIP64EOCDRecord = data.scanValue(start: 8)
        self.totalNumberOfDisk = data.scanValue(start: 16)
    }

    init(locator: Archive.ZIP64EndOfCentralDirectoryLocator, offsetOfZIP64EOCDRecord: UInt64) {
        self.numberOfDiskWithZIP64EOCDRecordStart = locator.numberOfDiskWithZIP64EOCDRecordStart
        self.relativeOffsetOfZIP64EOCDRecord = offsetOfZIP64EOCDRecord
        self.totalNumberOfDisk = locator.totalNumberOfDisk
    }
}

extension Archive.ZIP64EndOfCentralDirectory {
    var data: Data { record.data + locator.data }
}

/// Properties that represent the maximum value of each field
var maxUInt32 = UInt32.max
var maxUInt16 = UInt16.max

var maxCompressedSize: UInt32 { maxUInt32 }
var maxUncompressedSize: UInt32 { maxUInt32 }
var maxOffsetOfLocalFileHeader: UInt32 { maxUInt32 }
var maxOffsetOfCentralDirectory: UInt32 { maxUInt32 }
var maxSizeOfCentralDirectory: UInt32 { maxUInt32 }
var maxTotalNumberOfEntries: UInt16 { maxUInt16 }
