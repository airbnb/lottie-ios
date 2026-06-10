//
// DotLottieUtils.swift
// Lottie
//
// Created by Evandro Harrison Hoffmann on 27/06/2020.
//

import Foundation

// MARK: - DotLottieUtils

enum DotLottieUtils {
  static let dotLottieExtension = "lottie"
  static let jsonExtension = "json"
  /// IANA-approved short extension for the `video/lottie+json` media type.
  /// See https://www.iana.org/assignments/media-types/video/lottie+json
  /// Treated as an alias for `.json` everywhere a Lottie JSON animation is loaded.
  static let lotExtension = "lot"

  /// Temp folder to app directory
  static var tempDirectoryURL: URL {
    FileManager.default.temporaryDirectory
  }
}

extension URL {
  /// Checks if url is a lottie file
  var isDotLottie: Bool {
    pathExtension == DotLottieUtils.dotLottieExtension
  }

  /// Checks if url is a json file (`.json` or its IANA-registered alias `.lot`)
  var isJsonFile: Bool {
    pathExtension == DotLottieUtils.jsonExtension
      || pathExtension == DotLottieUtils.lotExtension
  }

  var urls: [URL] {
    FileManager.default.urls(for: self) ?? []
  }
}

extension FileManager {
  /// Lists urls for all files in a directory
  /// - Parameters:
  ///  - url: URL of directory to search
  ///  - skipsHiddenFiles: If should or not show hidden files
  /// - Returns: Returns urls of all files matching criteria in the directory
  func urls(for url: URL, skipsHiddenFiles: Bool = true) -> [URL]? {
    try? contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [])
  }
}

// MARK: - DotLottieError

public enum DotLottieError: Error {
  /// URL response has no data.
  case noDataLoaded
  /// Asset with this name was not found in the provided bundle.
  case assetNotFound(name: String, bundle: Bundle?)
  /// Animation loading from asset was not supported on macOS 10.10,
  /// but this error is no longer used.
  case loadingFromAssetNotSupported

  @available(*, deprecated, message: "Unused")
  case invalidFileFormat
  @available(*, deprecated, message: "Unused")
  case invalidData
  @available(*, deprecated, message: "Unused")
  case animationNotAvailable
}
