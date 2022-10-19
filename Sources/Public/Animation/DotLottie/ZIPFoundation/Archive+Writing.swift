//
//  Archive+Writing.swift
//  ZIPFoundation
//
//  Copyright © 2017-2021 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
//  Released under the MIT License.
//
//  See https://github.com/weichsel/ZIPFoundation/blob/master/LICENSE for license information.
//

import Foundation

extension Archive {
    enum ModifyOperation: Int {
        case remove = -1
        case add = 1
    }

    typealias EndOfCentralDirectoryStructure = (EndOfCentralDirectoryRecord, ZIP64EndOfCentralDirectory?)

    /// Write files, directories or symlinks to the receiver.
    ///
    /// - Parameters:
    ///   - path: The path that is used to identify an `Entry` within the `Archive` file.
    ///   - baseURL: The base URL of the resource to add.
    ///              The `baseURL` combined with `path` must form a fully qualified file URL.
    ///   - compressionMethod: Indicates the `CompressionMethod` that should be applied to `Entry`.
    ///                        By default, no compression will be applied.
    ///   - bufferSize: The maximum size of the write buffer and the compression buffer (if needed).
    ///   - progress: A progress object that can be used to track or cancel the add operation.
    /// - Throws: An error if the source file cannot be read or the receiver is not writable.
    public func addEntry(with path: String, relativeTo baseURL: URL,
                         compressionMethod: CompressionMethod = .none,
                         bufferSize: Int = defaultWriteChunkSize, progress: Progress? = nil) throws {
        let fileURL = baseURL.appendingPathComponent(path)

        try self.addEntry(with: path, fileURL: fileURL, compressionMethod: compressionMethod,
                          bufferSize: bufferSize, progress: progress)
    }

    /// Write files, directories or symlinks to the receiver.
    ///
    /// - Parameters:
    ///   - path: The path that is used to identify an `Entry` within the `Archive` file.
    ///   - fileURL: An absolute file URL referring to the resource to add.
    ///   - compressionMethod: Indicates the `CompressionMethod` that should be applied to `Entry`.
    ///                        By default, no compression will be applied.
    ///   - bufferSize: The maximum size of the write buffer and the compression buffer (if needed).
    ///   - progress: A progress object that can be used to track or cancel the add operation.
    /// - Throws: An error if the source file cannot be read or the receiver is not writable.
    public func addEntry(with path: String, fileURL: URL, compressionMethod: CompressionMethod = .none,
                         bufferSize: Int = defaultWriteChunkSize, progress: Progress? = nil) throws {
        let fileManager = FileManager()
        guard fileManager.itemExists(at: fileURL) else {
            throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: fileURL.path])
        }
        let type = try FileManager.typeForItem(at: fileURL)
        // symlinks do not need to be readable
        guard type == .symlink || fileManager.isReadableFile(atPath: fileURL.path) else {
            throw CocoaError(.fileReadNoPermission, userInfo: [NSFilePathErrorKey: url.path])
        }
        let modDate = try FileManager.fileModificationDateTimeForItem(at: fileURL)
        let uncompressedSize = type == .directory ? 0 : try FileManager.fileSizeForItem(at: fileURL)
        let permissions = try FileManager.permissionsForItem(at: fileURL)
        var provider: Provider
        switch type {
        case .file:
            let entryFileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: fileURL.path)
            guard let entryFile: FILEPointer = fopen(entryFileSystemRepresentation, "rb") else {
                throw CocoaError(.fileNoSuchFile)
            }
            defer { fclose(entryFile) }
            provider = { _, _ in return try Data.readChunk(of: bufferSize, from: entryFile) }
            try self.addEntry(with: path, type: type, uncompressedSize: uncompressedSize,
                              modificationDate: modDate, permissions: permissions,
                              compressionMethod: compressionMethod, bufferSize: bufferSize,
                              progress: progress, provider: provider)
        case .directory:
            provider = { _, _ in return Data() }
            try self.addEntry(with: path.hasSuffix("/") ? path : path + "/",
                              type: type, uncompressedSize: uncompressedSize,
                              modificationDate: modDate, permissions: permissions,
                              compressionMethod: compressionMethod, bufferSize: bufferSize,
                              progress: progress, provider: provider)
        case .symlink:
            provider = { _, _ -> Data in
                let linkDestination = try fileManager.destinationOfSymbolicLink(atPath: fileURL.path)
                let linkFileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: linkDestination)
                let linkLength = Int(strlen(linkFileSystemRepresentation))
                let linkBuffer = UnsafeBufferPointer(start: linkFileSystemRepresentation, count: linkLength)
                return Data(buffer: linkBuffer)
            }
            try self.addEntry(with: path, type: type, uncompressedSize: uncompressedSize,
                              modificationDate: modDate, permissions: permissions,
                              compressionMethod: compressionMethod, bufferSize: bufferSize,
                              progress: progress, provider: provider)
        }
    }

    /// Write files, directories or symlinks to the receiver.
    ///
    /// - Parameters:
    ///   - path: The path that is used to identify an `Entry` within the `Archive` file.
    ///   - type: Indicates the `Entry.EntryType` of the added content.
    ///   - uncompressedSize: The uncompressed size of the data that is going to be added with `provider`.
    ///   - modificationDate: A `Date` describing the file modification date of the `Entry`.
    ///                       Default is the current `Date`.
    ///   - permissions: POSIX file permissions for the `Entry`.
    ///                  Default is `0`o`644` for files and symlinks and `0`o`755` for directories.
    ///   - compressionMethod: Indicates the `CompressionMethod` that should be applied to `Entry`.
    ///                        By default, no compression will be applied.
    ///   - bufferSize: The maximum size of the write buffer and the compression buffer (if needed).
    ///   - progress: A progress object that can be used to track or cancel the add operation.
    ///   - provider: A closure that accepts a position and a chunk size. Returns a `Data` chunk.
    /// - Throws: An error if the source data is invalid or the receiver is not writable.
    public func addEntry(with path: String, type: Entry.EntryType, uncompressedSize: Int64,
                         modificationDate: Date = Date(), permissions: UInt16? = nil,
                         compressionMethod: CompressionMethod = .none, bufferSize: Int = defaultWriteChunkSize,
                         progress: Progress? = nil, provider: Provider) throws {
        guard self.accessMode != .read else { throw ArchiveError.unwritableArchive }
        // Directories and symlinks cannot be compressed
        let compressionMethod = type == .file ? compressionMethod : .none
        progress?.totalUnitCount = type == .directory ? defaultDirectoryUnitCount : uncompressedSize
        let (eocdRecord, zip64EOCD) = (self.endOfCentralDirectoryRecord, self.zip64EndOfCentralDirectory)
        guard self.offsetToStartOfCentralDirectory <= .max else { throw ArchiveError.invalidCentralDirectoryOffset }
        var startOfCD = Int64(self.offsetToStartOfCentralDirectory)
        fseeko(self.archiveFile, off_t(startOfCD), SEEK_SET)
        let existingSize = self.sizeOfCentralDirectory
        let existingData = try Data.readChunk(of: Int(existingSize), from: self.archiveFile)
        fseeko(self.archiveFile, off_t(startOfCD), SEEK_SET)
        let fileHeaderStart = Int64(ftello(self.archiveFile))
        let modDateTime = modificationDate.fileModificationDateTime
        defer { fflush(self.archiveFile) }
        do {
            // Local File Header
            var localFileHeader = try self.writeLocalFileHeader(path: path, compressionMethod: compressionMethod,
                                                                size: (UInt64(uncompressedSize), 0), checksum: 0,
                                                                modificationDateTime: modDateTime)
            // File Data
            let (written, checksum) = try self.writeEntry(uncompressedSize: uncompressedSize, type: type,
                                                          compressionMethod: compressionMethod, bufferSize: bufferSize,
                                                          progress: progress, provider: provider)
            startOfCD = Int64(ftello(self.archiveFile))
            // Write the local file header a second time. Now with compressedSize (if applicable) and a valid checksum.
            fseeko(self.archiveFile, off_t(fileHeaderStart), SEEK_SET)
            localFileHeader = try self.writeLocalFileHeader(path: path, compressionMethod: compressionMethod,
                                                            size: (UInt64(uncompressedSize), UInt64(written)),
                                                            checksum: checksum, modificationDateTime: modDateTime)
            // Central Directory
            fseeko(self.archiveFile, off_t(startOfCD), SEEK_SET)
            _ = try Data.writeLargeChunk(existingData, size: existingSize, bufferSize: bufferSize, to: archiveFile)
            let permissions = permissions ?? (type == .directory ? defaultDirectoryPermissions : defaultFilePermissions)
            let externalAttributes = FileManager.externalFileAttributesForEntry(of: type, permissions: permissions)
            let centralDir = try self.writeCentralDirectoryStructure(localFileHeader: localFileHeader,
                                                                     relativeOffset: UInt64(fileHeaderStart),
                                                                     externalFileAttributes: externalAttributes)
            // End of Central Directory Record (including ZIP64 End of Central Directory Record/Locator)
            let startOfEOCD = UInt64(ftello(self.archiveFile))
            let eocd = try self.writeEndOfCentralDirectory(centralDirectoryStructure: centralDir,
                                                           startOfCentralDirectory: UInt64(startOfCD),
                                                           startOfEndOfCentralDirectory: startOfEOCD, operation: .add)
            (self.endOfCentralDirectoryRecord, self.zip64EndOfCentralDirectory) = eocd
        } catch ArchiveError.cancelledOperation {
            try rollback(UInt64(fileHeaderStart), (existingData, existingSize), bufferSize, eocdRecord, zip64EOCD)
            throw ArchiveError.cancelledOperation
        }
    }

    /// Remove a ZIP `Entry` from the receiver.
    ///
    /// - Parameters:
    ///   - entry: The `Entry` to remove.
    ///   - bufferSize: The maximum size for the read and write buffers used during removal.
    ///   - progress: A progress object that can be used to track or cancel the remove operation.
    /// - Throws: An error if the `Entry` is malformed or the receiver is not writable.
    public func remove(_ entry: Entry, bufferSize: Int = defaultReadChunkSize, progress: Progress? = nil) throws {
        guard self.accessMode != .read else { throw ArchiveError.unwritableArchive }
        let (tempArchive, tempDir) = try self.makeTempArchive()
        defer { tempDir.map { try? FileManager().removeItem(at: $0) } }
        progress?.totalUnitCount = self.totalUnitCountForRemoving(entry)
        var centralDirectoryData = Data()
        var offset: UInt64 = 0
        for currentEntry in self {
            let cds = currentEntry.centralDirectoryStructure
            if currentEntry != entry {
                let entryStart = cds.effectiveRelativeOffsetOfLocalHeader
                fseeko(self.archiveFile, off_t(entryStart), SEEK_SET)
                let provider: Provider = { (_, chunkSize) -> Data in
                    return try Data.readChunk(of: chunkSize, from: self.archiveFile)
                }
                let consumer: Consumer = {
                    if progress?.isCancelled == true { throw ArchiveError.cancelledOperation }
                    _ = try Data.write(chunk: $0, to: tempArchive.archiveFile)
                    progress?.completedUnitCount += Int64($0.count)
                }
                guard currentEntry.localSize <= .max else { throw ArchiveError.invalidLocalHeaderSize }
                _ = try Data.consumePart(of: Int64(currentEntry.localSize), chunkSize: bufferSize,
                                         provider: provider, consumer: consumer)
                let updatedCentralDirectory = updateOffsetInCentralDirectory(centralDirectoryStructure: cds,
                                                                             updatedOffset: entryStart - offset)
                centralDirectoryData.append(updatedCentralDirectory.data)
            } else { offset = currentEntry.localSize }
        }
        let startOfCentralDirectory = UInt64(ftello(tempArchive.archiveFile))
        _ = try Data.write(chunk: centralDirectoryData, to: tempArchive.archiveFile)
        let startOfEndOfCentralDirectory = UInt64(ftello(tempArchive.archiveFile))
        tempArchive.endOfCentralDirectoryRecord = self.endOfCentralDirectoryRecord
        tempArchive.zip64EndOfCentralDirectory = self.zip64EndOfCentralDirectory
        let ecodStructure = try
            tempArchive.writeEndOfCentralDirectory(centralDirectoryStructure: entry.centralDirectoryStructure,
                                                   startOfCentralDirectory: startOfCentralDirectory,
                                                   startOfEndOfCentralDirectory: startOfEndOfCentralDirectory,
                                                   operation: .remove)
        (tempArchive.endOfCentralDirectoryRecord, tempArchive.zip64EndOfCentralDirectory) = ecodStructure
        (self.endOfCentralDirectoryRecord, self.zip64EndOfCentralDirectory) = ecodStructure
        fflush(tempArchive.archiveFile)
        try self.replaceCurrentArchive(with: tempArchive)
    }

    func replaceCurrentArchive(with archive: Archive) throws {
        fclose(self.archiveFile)
        if self.isMemoryArchive {
            #if swift(>=5.0)
            guard let data = archive.data,
                  let config = Archive.makeBackingConfiguration(for: data, mode: .update) else {
                throw ArchiveError.unwritableArchive
            }
            self.archiveFile = config.file
            self.memoryFile = config.memoryFile
            self.endOfCentralDirectoryRecord = config.endOfCentralDirectoryRecord
            self.zip64EndOfCentralDirectory = config.zip64EndOfCentralDirectory
            #endif
        } else {
            let fileManager = FileManager()
            #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            do {
                _ = try fileManager.replaceItemAt(self.url, withItemAt: archive.url)
            } catch {
                _ = try fileManager.removeItem(at: self.url)
                _ = try fileManager.moveItem(at: archive.url, to: self.url)
            }
            #else
            _ = try fileManager.removeItem(at: self.url)
            _ = try fileManager.moveItem(at: archive.url, to: self.url)
            #endif
            let fileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: self.url.path)
            guard let file = fopen(fileSystemRepresentation, "rb+") else { throw ArchiveError.unreadableArchive }
            self.archiveFile = file
        }
    }
}

// MARK: - Private

private extension Archive {

    func updateOffsetInCentralDirectory(centralDirectoryStructure: CentralDirectoryStructure,
                                        updatedOffset: UInt64) -> CentralDirectoryStructure {
        let zip64ExtendedInformation = Entry.ZIP64ExtendedInformation(
            zip64ExtendedInformation: centralDirectoryStructure.zip64ExtendedInformation, offset: updatedOffset)
        let offsetInCD = updatedOffset < maxOffsetOfLocalFileHeader ? UInt32(updatedOffset) : UInt32.max
        return CentralDirectoryStructure(centralDirectoryStructure: centralDirectoryStructure,
                                         zip64ExtendedInformation: zip64ExtendedInformation,
                                         relativeOffset: offsetInCD)
    }

    func rollback(_ localFileHeaderStart: UInt64, _ existingCentralDirectory: (data: Data, size: UInt64),
                  _ bufferSize: Int, _ endOfCentralDirRecord: EndOfCentralDirectoryRecord,
                  _ zip64EndOfCentralDirectory: ZIP64EndOfCentralDirectory?) throws {
        fflush(self.archiveFile)
        ftruncate(fileno(self.archiveFile), off_t(localFileHeaderStart))
        fseeko(self.archiveFile, off_t(localFileHeaderStart), SEEK_SET)
        _ = try Data.writeLargeChunk(existingCentralDirectory.data, size: existingCentralDirectory.size,
                                     bufferSize: bufferSize, to: archiveFile)
        _ = try Data.write(chunk: existingCentralDirectory.data, to: self.archiveFile)
        if let zip64EOCD = zip64EndOfCentralDirectory {
            _ = try Data.write(chunk: zip64EOCD.data, to: self.archiveFile)
        }
        _ = try Data.write(chunk: endOfCentralDirRecord.data, to: self.archiveFile)
    }

    func makeTempArchive() throws -> (Archive, URL?) {
        var archive: Archive
        var url: URL?
        if self.isMemoryArchive {
            #if swift(>=5.0)
            guard let tempArchive = Archive(data: Data(), accessMode: .create,
                                            preferredEncoding: self.preferredEncoding) else {
                throw ArchiveError.unwritableArchive
            }
            archive = tempArchive
            #else
            fatalError("Memory archives are unsupported.")
            #endif
        } else {
            let manager = FileManager()
            let tempDir = URL.temporaryReplacementDirectoryURL(for: self)
            let uniqueString = ProcessInfo.processInfo.globallyUniqueString
            let tempArchiveURL = tempDir.appendingPathComponent(uniqueString)
            try manager.createParentDirectoryStructure(for: tempArchiveURL)
            guard let tempArchive = Archive(url: tempArchiveURL, accessMode: .create) else {
                throw ArchiveError.unwritableArchive
            }
            archive = tempArchive
            url = tempDir
        }
        return (archive, url)
    }
}
