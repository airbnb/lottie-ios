//
//  FileManager+ZIP.swift
//  ZIPFoundation
//
//  Copyright © 2017-2025 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
//  Released under the MIT License.
//
//  See https://github.com/weichsel/ZIPFoundation/blob/master/LICENSE for license information.
//

import Foundation

extension FileManager {

    typealias CentralDirectoryStructure = Entry.CentralDirectoryStructure

    /// Zips the file or directory contents at the specified source URL to the destination URL.
    ///
    /// If the item at the source URL is a directory, the directory itself will be
    /// represented within the ZIP `Archive`. Calling this method with a directory URL
    /// `file:///path/directory/` will create an archive with a `directory/` entry at the root level.
    /// You can override this behavior by passing `false` for `shouldKeepParent`. In that case, the contents
    /// of the source directory will be placed at the root of the archive.
    /// - Parameters:
    ///   - sourceURL: The file URL pointing to an existing file or directory.
    ///   - destinationURL: The file URL that identifies the destination of the zip operation.
    ///   - shouldKeepParent: Indicates that the directory name of a source item should be used as root element
    ///                       within the archive. Default is `true`.
    ///   - compressionMethod: Indicates the `CompressionMethod` that should be applied.
    ///                        By default, `zipItem` will create uncompressed archives.
    ///   - progress: A progress object that can be used to track or cancel the zip operation.
    /// - Throws: Throws an error if the source item does not exist or the destination URL is not writable.
    func zipItem(at sourceURL: URL, to destinationURL: URL,
                        shouldKeepParent: Bool = true, compressionMethod: CompressionMethod = .none,
                        progress: Progress? = nil) throws {
        let fileManager = FileManager()
        guard fileManager.itemExists(at: sourceURL) else {
            throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: sourceURL.path])
        }
        guard !fileManager.itemExists(at: destinationURL) else {
            throw CocoaError(.fileWriteFileExists, userInfo: [NSFilePathErrorKey: destinationURL.path])
        }
        let archive = try Archive(url: destinationURL, accessMode: .create)
        let isDirectory = try FileManager.typeForItem(at: sourceURL) == .directory
        if isDirectory {
            var subPaths = try self.subpathsOfDirectory(atPath: sourceURL.path)
            // Enforce an entry for the root directory to preserve its file attributes
            if shouldKeepParent { subPaths.append("") }
            var totalUnitCount = Int64(0)
            if let progress = progress {
                totalUnitCount = subPaths.reduce(Int64(0), {
                    let itemURL = sourceURL.appendingPathComponent($1)
                    let itemSize = archive.totalUnitCountForAddingItem(at: itemURL)
                    return $0 + itemSize
                })
                progress.totalUnitCount = totalUnitCount
            }

            // If the caller wants to keep the parent directory, we use the lastPathComponent of the source URL
            // as common base for all entries (similar to macOS' Archive Utility.app)
            let directoryPrefix = sourceURL.lastPathComponent
            for entryPath in subPaths {
                let finalEntryPath = shouldKeepParent ? directoryPrefix + "/" + entryPath : entryPath
                let finalBaseURL = shouldKeepParent ? sourceURL.deletingLastPathComponent() : sourceURL
                if let progress = progress {
                    let itemURL = sourceURL.appendingPathComponent(entryPath)
                    let entryProgress = archive.makeProgressForAddingItem(at: itemURL)
                    progress.addChild(entryProgress, withPendingUnitCount: entryProgress.totalUnitCount)
                    try archive.addEntry(with: finalEntryPath, relativeTo: finalBaseURL,
                                         compressionMethod: compressionMethod, progress: entryProgress)
                } else {
                    try archive.addEntry(with: finalEntryPath, relativeTo: finalBaseURL,
                                         compressionMethod: compressionMethod)
                }
            }
        } else {
            progress?.totalUnitCount = archive.totalUnitCountForAddingItem(at: sourceURL)
            let baseURL = sourceURL.deletingLastPathComponent()
            try archive.addEntry(with: sourceURL.lastPathComponent, relativeTo: baseURL,
                                 compressionMethod: compressionMethod, progress: progress)
        }
    }

    /// Unzips the contents at the specified source URL to the destination URL.
    ///
    /// - Parameters:
    ///   - sourceURL: The file URL pointing to an existing ZIP file.
    ///   - destinationURL: The file URL that identifies the destination directory of the unzip operation.
    ///   - skipCRC32: Optional flag to skip calculation of the CRC32 checksum to improve performance.
    ///   - allowUncontainedSymlinks: Optional flag to allow symlinks that point to paths outside the destination.
    ///   - progress: A progress object that can be used to track or cancel the unzip operation.
    ///   - pathEncoding: Encoding for entry paths. Overrides the encoding specified in the archive.
    /// - Throws: Throws an error if the source item does not exist or the destination URL is not writable.
    func unzipItem(at sourceURL: URL, to destinationURL: URL,
                          skipCRC32: Bool = false, allowUncontainedSymlinks: Bool = false,
                          progress: Progress? = nil, pathEncoding: String.Encoding? = nil) throws {
        let fileManager = FileManager()
        guard fileManager.itemExists(at: sourceURL) else {
            throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: sourceURL.path])
        }
        let archive = try Archive(url: sourceURL, accessMode: .read, pathEncoding: pathEncoding)
        var totalUnitCount = Int64(0)
        if let progress = progress {
            totalUnitCount = archive.reduce(0, { $0 + archive.totalUnitCountForReading($1) })
            progress.totalUnitCount = totalUnitCount
        }

        for entry in archive {
            let path = pathEncoding == nil ? entry.path : entry.path(using: pathEncoding!)
            let entryURL = destinationURL.appendingPathComponent(path)
            guard entryURL.isContained(in: destinationURL) else {
                throw CocoaError(.fileReadInvalidFileName,
                                 userInfo: [NSFilePathErrorKey: entryURL.path])
            }
            let crc32: CRC32
            if let progress = progress {
                let entryProgress = archive.makeProgressForReading(entry)
                progress.addChild(entryProgress, withPendingUnitCount: entryProgress.totalUnitCount)
                crc32 = try archive.extract(entry, to: entryURL,
                                            skipCRC32: skipCRC32, allowUncontainedSymlinks: allowUncontainedSymlinks,
                                            progress: entryProgress)
            } else {
                crc32 = try archive.extract(entry, to: entryURL,
                                            skipCRC32: skipCRC32, allowUncontainedSymlinks: allowUncontainedSymlinks)
            }

            func verifyChecksumIfNecessary() throws {
                if skipCRC32 == false, crc32 != entry.checksum {
                    throw Archive.ArchiveError.invalidCRC32
                }
            }
            try verifyChecksumIfNecessary()
        }
    }

    // MARK: - Helpers

    func itemExists(at url: URL) -> Bool {
        // Use `URL.checkResourceIsReachable()` instead of `FileManager.fileExists()` here
        // because we don't want implicit symlink resolution.
        // As per documentation, `FileManager.fileExists()` traverses symlinks and therefore a broken symlink
        // would throw a `.fileReadNoSuchFile` false positive error.
        // For ZIP files it may be intended to archive "broken" symlinks because they might be
        // resolvable again when extracting the archive to a different destination.
        return (try? url.checkResourceIsReachable()) == true
    }

    func createParentDirectoryStructure(for url: URL) throws {
        let parentDirectoryURL = url.deletingLastPathComponent()
        try self.createDirectory(at: parentDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    }

    func transferAttributes(from entry: Entry, toItemAtURL url: URL) throws {
        let attributes = FileManager.attributes(from: entry)
        switch entry.type {
        case .directory, .file:
            try self.setAttributes(attributes, ofItemAtURL: url)
        case .symlink:
            try self.setAttributes(attributes, ofItemAtURL: url, traverseLink: false)
        }
    }

    func setAttributes(_ attributes: [FileAttributeKey: Any], ofItemAtURL url: URL, traverseLink: Bool = true) throws {
        // `FileManager.setAttributes` traverses symlinks and applies the attributes to
        // the symlink destination. Since we want to be able to create symlinks where
        // the destination isn't available (yet), we want to directly apply entry attributes
        // to the symlink (vs. the destination file).
        guard traverseLink == false else {
            try self.setAttributes(attributes, ofItemAtPath: url.path)
            return
        }

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
        guard let posixPermissions = attributes[.posixPermissions] as? NSNumber else {
            throw Entry.EntryError.missingPermissionsAttributeError
        }

        try self.setSymlinkPermissions(posixPermissions, ofItemAtURL: url)

        guard let modificationDate = attributes[.modificationDate] as? Date else {
            throw Entry.EntryError.missingModificationDateAttributeError
        }

        try self.setSymlinkModificationDate(modificationDate, ofItemAtURL: url)
#else
        // Since non-Darwin POSIX platforms ignore permissions on symlinks and swift-corelibs-foundation
        // currently doesn't support setting the modification date, this codepath is currently a no-op
        // on these platforms.
        return
#endif
    }

    func setSymlinkPermissions(_ posixPermissions: NSNumber, ofItemAtURL url: URL) throws {
        let fileSystemRepresentation = self.fileSystemRepresentation(withPath: url.path)
        let modeT = posixPermissions.uint16Value
        guard lchmod(fileSystemRepresentation, mode_t(modeT)) == 0 else {
            throw POSIXError(errno, path: url.path)
        }
    }

    func setSymlinkModificationDate(_ modificationDate: Date, ofItemAtURL url: URL) throws {
        let fileSystemRepresentation = self.fileSystemRepresentation(withPath: url.path)
        var fileStat = stat()
        guard lstat(fileSystemRepresentation, &fileStat) == 0 else {
            throw POSIXError(errno, path: url.path)
        }

        let accessDate = fileStat.lastAccessDate
        let array = [
            timeval(timeIntervalSince1970: accessDate.timeIntervalSince1970),
            timeval(timeIntervalSince1970: modificationDate.timeIntervalSince1970)
        ]
        try array.withUnsafeBufferPointer {
            guard lutimes(fileSystemRepresentation, $0.baseAddress) == 0 else {
                throw POSIXError(errno, path: url.path)
            }
        }
    }

    class func attributes(from entry: Entry) -> [FileAttributeKey: Any] {
        let centralDirectoryStructure = entry.centralDirectoryStructure
        let entryType = entry.type
        let fileTime = centralDirectoryStructure.lastModFileTime
        let fileDate = centralDirectoryStructure.lastModFileDate
        let defaultPermissions = entryType == .directory ? defaultDirectoryPermissions : defaultFilePermissions
        var attributes = [.posixPermissions: defaultPermissions] as [FileAttributeKey: Any]
        attributes[.modificationDate] = Date(dateTime: (fileDate, fileTime))
        let versionMadeBy = centralDirectoryStructure.versionMadeBy
        guard let osType = Entry.OSType(rawValue: UInt(versionMadeBy >> 8)) else { return attributes }

        let externalFileAttributes = centralDirectoryStructure.externalFileAttributes
        let permissions = self.permissions(for: externalFileAttributes, osType: osType, entryType: entryType)
        attributes[.posixPermissions] = NSNumber(value: permissions)
        return attributes
    }

    class func permissions(for externalFileAttributes: UInt32, osType: Entry.OSType,
                           entryType: Entry.EntryType) -> UInt16 {
        switch osType {
        case .unix, .osx:
            let permissions = mode_t(externalFileAttributes >> 16) & (~S_IFMT)
            let defaultPermissions = entryType == .directory ? defaultDirectoryPermissions : defaultFilePermissions
            return permissions == 0 ? defaultPermissions : UInt16(permissions)
        default:
            return entryType == .directory ? defaultDirectoryPermissions : defaultFilePermissions
        }
    }

    class func externalFileAttributesForEntry(of type: Entry.EntryType, permissions: UInt16) -> UInt32 {
        var typeInt: UInt16
        switch type {
        case .file:
            typeInt = UInt16(S_IFREG)
        case .directory:
            typeInt = UInt16(S_IFDIR)
        case .symlink:
            typeInt = UInt16(S_IFLNK)
        }
        var externalFileAttributes = UInt32(typeInt|UInt16(permissions))
        externalFileAttributes = (externalFileAttributes << 16)
        return externalFileAttributes
    }

    class func permissionsForItem(at URL: URL) throws -> UInt16 {
        let fileManager = FileManager()
        let entryFileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: URL.path)
        var fileStat = stat()
        lstat(entryFileSystemRepresentation, &fileStat)
        let permissions = fileStat.st_mode
        return UInt16(permissions)
    }

    class func fileModificationDateTimeForItem(at url: URL) throws -> Date {
        let fileManager = FileManager()
        guard fileManager.itemExists(at: url) else {
            throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: url.path])
        }
        let entryFileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: url.path)
        var fileStat = stat()
        lstat(entryFileSystemRepresentation, &fileStat)
#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
        let modTimeSpec = fileStat.st_mtimespec
#else
        let modTimeSpec = fileStat.st_mtim
#endif

        let timeStamp = TimeInterval(modTimeSpec.tv_sec) + TimeInterval(modTimeSpec.tv_nsec)/1000000000.0
        let modDate = Date(timeIntervalSince1970: timeStamp)
        return modDate
    }

    class func fileSizeForItem(at url: URL) throws -> Int64 {
        let fileManager = FileManager()
        guard fileManager.itemExists(at: url) else {
            throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: url.path])
        }

        let entryFileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: url.path)
        var stats = stat()
        lstat(entryFileSystemRepresentation, &stats)
        guard stats.st_size >= 0 else { throw CocoaError(.fileReadTooLarge, userInfo: [NSFilePathErrorKey: url.path]) }

        // `st_size` is a signed int value
        return Int64(stats.st_size)
    }

    class func typeForItem(at url: URL) throws -> Entry.EntryType {
        let fileManager = FileManager()
        guard url.isFileURL, fileManager.itemExists(at: url) else {
            throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: url.path])
        }
        let entryFileSystemRepresentation = fileManager.fileSystemRepresentation(withPath: url.path)
        var fileStat = stat()
        lstat(entryFileSystemRepresentation, &fileStat)
        return Entry.EntryType(mode: mode_t(fileStat.st_mode))
    }
}

extension POSIXError {

    init(_ code: Int32, path: String) {
        let errorCode = POSIXError.Code(rawValue: code) ?? .EPERM
        self = .init(errorCode, userInfo: [NSFilePathErrorKey: path])
    }
}

extension CocoaError {

#if swift(>=4.2)
#else

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
#else

    // The swift-corelibs-foundation version of NSError.swift was missing a convenience method to create
    // error objects from error codes. (https://github.com/apple/swift-corelibs-foundation/pull/1420)
    // We have to provide an implementation for non-Darwin platforms using Swift versions < 4.2.

    static func error(_ code: CocoaError.Code, userInfo: [AnyHashable: Any]? = nil, url: URL? = nil) -> Error {
        var info: [String: Any] = userInfo as? [String: Any] ?? [:]
        if let url = url {
            info[NSURLErrorKey] = url
        }
        return NSError(domain: NSCocoaErrorDomain, code: code.rawValue, userInfo: info)
    }

#endif
#endif
}

extension URL {

    func isContained(in parentDirectoryURL: URL) -> Bool {
        // Ensure this URL is contained in the passed in URL
        let parentDirectoryURL = URL(fileURLWithPath: parentDirectoryURL.path, isDirectory: true).standardized
        // Maliciously crafted ZIP files can contain entries using a prepended path delimiter `/` in combination
        // with the parent directory shorthand `..` to bypass our containment check.
        // When a malicious entry path like e.g. `/../secret.txt` gets appended to the destination 
        // directory URL (e.g. `file:///tmp/`), the resulting URL `file:///tmp//../secret.txt` gets expanded
        // to `file:///tmp/secret` when using `URL.standardized`. This URL would pass the check performed
        // in `isContained(in:)`.
        // Lower level API like POSIX `fopen` - which is used at a later point during extraction - expands
        // `/tmp//../secret.txt` to `/secret.txt` though. This would lead to an escape to the parent directory.
        // To avoid that, we replicate the behavior of `fopen`s path expansion and replace all double delimiters
        // with single delimiters.
        // More details: https://github.com/weichsel/ZIPFoundation/issues/281
        let sanitizedEntryPathURL: URL = {
            let sanitizedPath = self.path.replacingOccurrences(of: "//", with: "/")
            return URL(fileURLWithPath: sanitizedPath)
        }()
        return sanitizedEntryPathURL.standardized.absoluteString.hasPrefix(parentDirectoryURL.absoluteString)
    }
}
