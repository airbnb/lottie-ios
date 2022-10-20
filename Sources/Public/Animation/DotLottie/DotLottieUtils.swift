//
// DotLottieUtils.swift
// LottieFiles
//
// Created by Evandro Harrison Hoffmann on 27/06/2020.
// Copyright © 2020 LottieFiles. All rights reserved.
//

import Foundation

struct DotLottieUtils {
  static let dotLottieExtension = "lottie"
  static let jsonExtension = "json"
  
  /// Temp folder to app directory
  static var tempDirectoryURL: URL {
    if #available(iOS 10.0, *) {
      return FileManager.default.temporaryDirectory
    }
    return URL(fileURLWithPath: NSTemporaryDirectory())
  }
}

extension URL {
  /// Checks if url is a lottie file
  var isDotLottie: Bool {
    pathExtension == DotLottieUtils.dotLottieExtension
  }
  
  /// Checks if url is a json file
  var isJsonFile: Bool {
    pathExtension == DotLottieUtils.jsonExtension
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
  func urls(for url: URL, skipsHiddenFiles: Bool = true ) -> [URL]? {
    try? contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [])
  }
}

public enum DotLottieError: Error {
  case invalidFileFormat
  case invalidData
  case animationNotAvailable
}
