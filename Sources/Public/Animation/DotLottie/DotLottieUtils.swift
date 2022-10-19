//
// DotLottieUtils.swift
// LottieFiles
//
// Created by Evandro Harrison Hoffmann on 27/06/2020.
// Copyright © 2020 LottieFiles. All rights reserved.
//

import Foundation

public struct DotLottieUtils {
  public static let dotLottieExtension = "lottie"
  public static let jsonExtension = "json"
  
  /// Enables log printing
  public static var isLogEnabled: Bool = false
  
  /// Prints log if enabled
  /// - Parameter text: Text to log
  public static func log(_ text: String) {
    guard isLogEnabled else { return }
    print("[dotLottie] \(text)")
  }
  
  /// Temp folder to app directory
  public static var tempDirectoryURL: URL {
    if #available(iOS 10.0, *) {
      return FileManager.default.temporaryDirectory
    }
    
    return URL(fileURLWithPath: NSTemporaryDirectory())
  }
  
  /// Temp animations folder
  public static var animationsDirectoryURL: URL {
    DotLottieUtils.tempDirectoryURL.appendingPathComponent("animations")
  }
  
  /// Returns url for animations foder with animation name
  /// - Parameter url: Animation url
  /// - Returns: url to animation temp folder
  public static func animationsDirectoryURL(for url: URL) -> URL {
    animationsDirectoryURL.appendingPathComponent(url.lastPathComponent)
  }
  
  /// Temp downloads folder
  public static var downloadsDirectoryURL: URL {
    DotLottieUtils.tempDirectoryURL.appendingPathComponent("downloads")
  }
  
  /// Returns temp download url for file
  /// - Parameter url: Animation url
  /// - Returns: url to animation temp folder
  public static func downloadsDirectoryURL(for url: URL) -> URL {
    DotLottieUtils.downloadsDirectoryURL.appendingPathComponent(url.lastPathComponent)
  }
  
  /// Returns url to file in local bundle with given name
  /// - Parameter name: name of animation file
  /// - Returns: URL to local animation
  public static func bundleURL(for name: String) -> URL? {
    guard let url = Bundle.main.url(forResource: name, withExtension: dotLottieExtension, subdirectory: nil) else {
      guard let url = Bundle.main.url(forResource: name, withExtension: jsonExtension, subdirectory: nil) else {
        return nil
      }
      return url
    }
    return url
  }
}

extension URL {
  
  /// Checks if url is a lottie file
  public var isDotLottieFile: Bool {
    pathExtension == DotLottieUtils.dotLottieExtension
  }
  
  /// Checks if url is a json file
  public var isJsonFile: Bool {
    pathExtension == DotLottieUtils.jsonExtension
  }
  
  /// Checks if url has already been downloaded
  public var isLottieFileDownloaded: Bool {
    let url = DotLottieUtils.downloadsDirectoryURL(for: self)
    return FileManager.default.fileExists(atPath: url.path)
  }
  
  /// Checks if url has been decompressed
  public var isLottieFileDecompressed: Bool {
    let url = DotLottieUtils.animationsDirectoryURL(for: self)
      .appendingPathComponent(DotLottieFile.animationsFolderName)
    var isDirectory: ObjCBool = false
    if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
      return isDirectory.boolValue
    }
    
    return false
  }
  
  /// Checks if file is remote
  public var isRemoteFile: Bool {
    absoluteString.contains("http")
  }
  
  public var urls: [URL] {
    FileManager.default.urls(for: self) ?? []
  }
}

extension FileManager {
  /// Lists urls for all files in a directory
  /// - Parameters:
  ///  - url: URL of directory to search
  ///  - skipsHiddenFiles: If should or not show hidden files
  /// - Returns: Returns urls of all files matching criteria in the directory
  public func urls(for url: URL, skipsHiddenFiles: Bool = true ) -> [URL]? {
    try? contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [])
  }
}

public enum DotLottieError: Error {
  case invalidFileFormat
  case invalidData
  case animationNotAvailable
}
