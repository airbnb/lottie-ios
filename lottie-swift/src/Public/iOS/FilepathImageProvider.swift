//
//  FilepathImageProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/1/19.
//

import Foundation
import UIKit

/**
 Provides an image for a lottie animation from a provided Bundle.
 */
public class FilepathImageProvider: AnimationImageProvider {
  
  let filepath: URL
  
  /**
   Initializes an image provider with a specific filepath.
   
   - Parameter filepath: The absolute filepath containing the images.
   
   */
  public init(filepath: String) {
    self.filepath = URL(fileURLWithPath: filepath)
  }
  
  public init(filepath: URL) {
    self.filepath = filepath
  }
  
  public func imageForAsset(asset: ImageAsset) -> CGImage? {

    let directPath = filepath.appendingPathComponent(asset.name).path
    if FileManager.default.fileExists(atPath: directPath) {
      return UIImage(contentsOfFile: directPath)?.cgImage
    }
    
    let pathWithDirectory = filepath.appendingPathComponent(asset.directory).appendingPathComponent(asset.name).path
    if FileManager.default.fileExists(atPath: pathWithDirectory) {
      return UIImage(contentsOfFile: pathWithDirectory)?.cgImage
    }
    
    return nil
  }
  
}
