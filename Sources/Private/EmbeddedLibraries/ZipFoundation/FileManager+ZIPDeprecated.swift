//
//  FileManager+ZIPDeprecated.swift
//  ZIPFoundation
//
//  Created by Thomas Zoechling on 06.02.23.
//

import Foundation

extension FileManager {

    @available(*, deprecated, renamed: "unzipItem(at:to:skipCRC32:progress:pathEncoding:)")
    func unzipItem(at sourceURL: URL, to destinationURL: URL, skipCRC32: Bool = false,
                   progress: Progress? = nil, preferredEncoding: String.Encoding?) throws {
        try self.unzipItem(at: sourceURL, to: destinationURL, skipCRC32: skipCRC32,
                           progress: progress, pathEncoding: preferredEncoding)
    }
}
