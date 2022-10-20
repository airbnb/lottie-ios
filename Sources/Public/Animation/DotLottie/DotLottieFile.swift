//
// DotLottieFile.swift
// LottieFiles
//
// Created by Evandro Harrison Hoffmann on 27/06/2020.
// Copyright © 2020 LottieFiles. All rights reserved.
//

import Foundation
import ZIPFoundation

/// Detailed .lottie file structure
public struct DotLottieFile {
  let localUrl: URL
  
  static let manifestFileName: String = "manifest.json"
  static let animationsFolderName: String = "animations"
  static let imagesFolderName: String = "images"
  
  /// Manifest.json file loading
  var manifest: DotLottieManifest? {
    let path = localUrl.appendingPathComponent(DotLottieFile.manifestFileName)
    return try? DotLottieManifest.load(from: path)
  }
  
  /// Animation url for main animation
  var animationUrl: URL? {
    guard let animationId = manifest?.animations.first?.id else { return nil }
    let dotLottieJson = "\(DotLottieFile.animationsFolderName)/\(animationId).json"
    return localUrl.appendingPathComponent(dotLottieJson)
  }
  
  /// Animations folder url
  var animationsUrl: URL {
    localUrl.appendingPathComponent("\(DotLottieFile.animationsFolderName)")
  }
  
  /// All files in animations folder
  var animationUrls: [URL] {
    FileManager.default.urls(for: animationsUrl) ?? []
  }
  
  /// Images folder url
  var imagesUrl: URL {
    localUrl.appendingPathComponent("\(DotLottieFile.imagesFolderName)")
  }
  
  /// All images in images folder
  var imageUrls: [URL] {
    FileManager.default.urls(for: imagesUrl) ?? []
  }
    
  /// Loads `DotLottieFile` from `URL` containing .lottie file.
  ///
  /// - Parameters:
  ///  - url: URL to .lottie file
  ///  - Returns: Deserialized `DotLottieFile`. Optional.
  init(url: URL) throws {
    self.localUrl = DotLottieUtils.tempDirectoryURL.appendingPathComponent(url.deletingPathExtension().lastPathComponent)
    guard url.isDotLottieFile else {
      throw DotLottieError.invalidFileFormat
    }
    try decompress(from: url, in: localUrl)
  }
  
  /// Loads `DotLottieFile` from `Data` object containing a compressed animation.
  ///
  /// - Parameters:
  ///  - data: Data of .lottie file
  ///  - Returns: Deserialized `DotLottieFile`. Optional.
  init(data: Data, filename: String = UUID().uuidString) throws {
    self.localUrl = DotLottieUtils.tempDirectoryURL.appendingPathComponent(filename)
    try decompress(data: data, filename: filename, in: localUrl)
  }
  
  /// Decompresses .lottie file from `URL` and saves to local temp folder
  ///
  /// - Parameters:
  ///  - url: url to .lottie file
  ///  - directory: url to destination of decompression contents
  private func decompress(from url: URL, in directory: URL) throws {
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    try FileManager.default.unzipItem(at: url, to: directory)
  }
    
    /// Decompresses .lottie file from `Data` and saves to local temp folder
    ///
    /// - Parameters:
    ///  - url: url to .lottie file
    ///  - directory: url to destination of decompression contents
  private func decompress(data: Data, filename: String, in directory: URL) throws {
    let url = DotLottieUtils.tempDirectoryURL.appendingPathComponent("\(filename).lottie")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    try data.write(to: url)
    try decompress(from: url, in: directory)
    try? FileManager.default.removeItem(at: url)
  }
}
