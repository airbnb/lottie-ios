//
// DotLottieFile.swift
// LottieFiles
//
// Created by Evandro Harrison Hoffmann on 27/06/2020.
// Copyright © 2020 LottieFiles. All rights reserved.
//

import Foundation

/// Detailed .lottie file structure
public struct DotLottieFile {
  public let localUrl: URL
  
  public static let manifestFileName: String = "manifest.json"
  public static let animationsFolderName: String = "animations"
  public static let imagesFolderName: String = "images"
  
  /// Manifest.json file loading
  public var manifest: DotLottieManifest? {
    let path = localUrl.appendingPathComponent(DotLottieFile.manifestFileName)
    do {
      return try DotLottieManifest.load(from: path)
    } catch {
      return nil
    }
  }
  
  /// Animation url for main animation
  public var animationUrl: URL? {
    guard let animationId = manifest?.animations.first?.id else { return nil }
    let dotLottieJson = "\(DotLottieFile.animationsFolderName)/\(animationId).json"
    return localUrl.appendingPathComponent(dotLottieJson)
  }
  
  /// Animations folder url
  public var animationsUrl: URL {
    localUrl.appendingPathComponent("\(DotLottieFile.animationsFolderName)")
  }
  
  /// All files in animations folder
  public var animations: [URL] {
    FileManager.default.urls(for: animationsUrl) ?? []
  }
  
  /// Images folder url
  public var imagesUrl: URL {
    localUrl.appendingPathComponent("\(DotLottieFile.imagesFolderName)")
  }
  
  /// All images in images folder
  public var images: [URL] {
    FileManager.default.urls(for: imagesUrl) ?? []
  }
  
  /// Returns main (first) lottie animation of file
  public func mainAnimation() throws -> LottieAnimation {
    guard let dotLottieAnimation = manifest?.animations.first,
          let animationUrl = animations.first(where: { $0.deletingPathExtension().lastPathComponent == dotLottieAnimation.id }) else {
      throw DotLottieError.animationNotAvailable
    }
    
    let jsonData = try Data(contentsOf: animationUrl)
    let animation = try LottieAnimation.from(data: jsonData)
    animation.dotLottieConfiguration = DotLottieConfiguration(file: self, animation: dotLottieAnimation)
    return animation
  }

  /// Image provider for `LottieAnimationView`
  public var imageProvider: FilepathImageProvider? {
    !images.isEmpty ? FilepathImageProvider(filepath: imagesUrl) : nil
  }
    
  /// Constructor with url.
  /// Returns nil if is not a .lottie file and decompression failed
  /// - Parameters:
  ///  - url: URL to .lottie file
  public init(url: URL) throws {
    self.localUrl = DotLottieUtils.animationsDirectoryURL(for: url)
    guard url.isDotLottieFile else {
      throw DotLottieError.invalidFileFormat
    }
    try decompress(from: url, in: localUrl)
  }
  
  /// Constructor with data
  /// - Parameters:
  ///  - data: Data of .lottie file
  public init(data: Data, filename: String = UUID().uuidString) throws {
    self.localUrl = DotLottieUtils.animationsDirectoryURL.appendingPathComponent(filename)
    try decompress(data: data, filename: filename, in: localUrl)
  }
  
  /// Decompresses .lottie file and saves to local temp folder
  /// - Parameters:
  ///  - url: url to .lottie file
  ///  - directory: url to destination of decompression contents
  /// - Returns: success true/false
  private func decompress(from url: URL, in directory: URL) throws {
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    try FileManager.default.unzipItem(at: url, to: directory)
    DotLottieUtils.log("File decompressed to \(directory.path)")
  }
  
  /// Decompresses .lottie file and saves to local temp folder
  /// - Parameters:
  ///  - data: Data of .lottie file
  ///  - directory: url to destination of decompression contents
  /// - Returns: success true/false
  private func decompress(data: Data, filename: String, in directory: URL) throws {
    let url = DotLottieUtils.animationsDirectoryURL.appendingPathComponent("\(filename).lottie")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    try data.write(to: url)
    try decompress(from: url, in: directory)
    DotLottieUtils.log("File decompressed to \(directory.path)")
    try? FileManager.default.removeItem(at: url) // removes temp file
  }
}

