//
// DotLottie.swift
// LottieFiles
//
// Created by Evandro Harrison Hoffmann on 27/06/2020.
// Copyright © 2020 LottieFiles. All rights reserved.
//

import Foundation
import ZIPFoundation

// MARK: - DotLottie

/// Detailed .lottie file structure
public final class DotLottie {

  // MARK: Lifecycle

  /// Loads `DotLottie` from `URL` containing .lottie file.
  ///
  /// - Parameters:
  ///  - url: URL to .lottie file
  ///  - Returns: Deserialized `DotLottie`. Optional.
  init(url: URL) throws {
    fileUrl = DotLottieUtils.tempDirectoryURL.appendingPathComponent(url.deletingPathExtension().lastPathComponent)
    guard url.isDotLottie else {
      throw DotLottieError.invalidFileFormat
    }
    try decompress(from: url, to: fileUrl)
  }

  /// Loads `DotLottie` from `Data` object containing a compressed animation.
  ///
  /// - Parameters:
  ///  - data: Data of .lottie file
  ///  - filename: Name of .lottie file
  ///  - Returns: Deserialized `DotLottie`. Optional.
  init(data: Data, filename: String) throws {
    fileUrl = DotLottieUtils.tempDirectoryURL.appendingPathComponent(filename.asFilename())
    try decompress(data: data, to: fileUrl)
  }

  // MARK: Public

  /// List of `LottieAnimation` in the file
  public var animations: [LottieAnimation] = []

  /// Image provider for animations
  public var imageProvider: AnimationImageProvider?

  // MARK: Internal

  /// Manifest.json file loading
  var manifest: DotLottieManifest? {
    let path = fileUrl.appendingPathComponent(DotLottie.manifestFileName)
    return try? DotLottieManifest.load(from: path)
  }

  /// Animation url for main animation
  var animationUrl: URL? {
    guard let animationId = manifest?.animations.first?.id else { return nil }
    let dotLottieJson = "\(DotLottie.animationsFolderName)/\(animationId).json"
    return fileUrl.appendingPathComponent(dotLottieJson)
  }

  /// Animations folder url
  var animationsUrl: URL {
    fileUrl.appendingPathComponent("\(DotLottie.animationsFolderName)")
  }

  /// All files in animations folder
  var animationUrls: [URL] {
    FileManager.default.urls(for: animationsUrl) ?? []
  }

  /// Images folder url
  var imagesUrl: URL {
    fileUrl.appendingPathComponent("\(DotLottie.imagesFolderName)")
  }

  /// All images in images folder
  var imageUrls: [URL] {
    FileManager.default.urls(for: imagesUrl) ?? []
  }

  // MARK: Private

  private static let manifestFileName = "manifest.json"
  private static let animationsFolderName = "animations"
  private static let imagesFolderName = "images"

  private let fileUrl: URL

  /// Decompresses .lottie file from `URL` and saves to local temp folder
  ///
  /// - Parameters:
  ///  - url: url to .lottie file
  ///  - destinationURL: url to destination of decompression contents
  private func decompress(from url: URL, to destinationURL: URL) throws {
    try? FileManager.default.removeItem(at: destinationURL)
    try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
    try FileManager.default.unzipItem(at: url, to: destinationURL)
    loadContent()
    try? FileManager.default.removeItem(at: destinationURL)
    try? FileManager.default.removeItem(at: url)
  }

  /// Decompresses .lottie file from `Data` and saves to local temp folder
  ///
  /// - Parameters:
  ///  - url: url to .lottie file
  ///  - destinationURL: url to destination of decompression contents
  private func decompress(data: Data, to destinationURL: URL) throws {
    let url = destinationURL.appendingPathExtension("lottie")
    try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
    try data.write(to: url)
    try decompress(from: url, to: destinationURL)
  }

  /// Loads file content to memory
  private func loadContent() {
    imageProvider = DotLottieImageProvider(filepath: imagesUrl)

    animations = dotLottieAnimations.compactMap {
      let animation = try? $0.animation()
      animation?.dotLottieConfiguration = DotLottieConfiguration(
        imageProvider: imageProvider,
        loopMode: $0.loopMode,
        speed: $0.animationSpeed)
      return animation
    }
  }
}

extension String {

  // MARK: Fileprivate

  fileprivate func asFilename() -> String {
    lastPathComponent().removingPathExtension()
  }

  fileprivate func lastPathComponent() -> String {
    (self as NSString).lastPathComponent
  }

  // MARK: Private

  private func removingPathExtension() -> String {
    (self as NSString).deletingPathExtension
  }
}
