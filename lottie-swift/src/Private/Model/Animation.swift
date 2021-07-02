//
//  Animation.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/7/19.
//

import Foundation

public enum CoordinateSpace: Int, Codable {
  case type2d
  case type3d
}

/**
 The `Animation` model is the top level model object in Lottie.
 
 An `Animation` holds all of the animation data backing a Lottie Animation.
 Codable, see JSON schema [here](https://github.com/airbnb/lottie-web/tree/master/docs/json).
 */
public final class Animation: Codable, DictionaryInitializable {
  
  /// The version of the JSON Schema.
  let version: String
  
  /// The coordinate space of the composition.
  let type: CoordinateSpace
  
  /// The start time of the composition in frameTime.
  public let startFrame: AnimationFrameTime
  
  /// The end time of the composition in frameTime.
  public let endFrame: AnimationFrameTime
  
  /// The frame rate of the composition.
  public let framerate: Double
  
  /// The height of the composition in points.
  let width: Int
  
  /// The width of the composition in points.
  let height: Int
  
  /// The list of animation layers
  let layers: [LayerModel]
  
  /// The list of glyphs used for text rendering
  let glyphs: [Glyph]?
  
  /// The list of fonts used for text rendering
  let fonts: FontList?
  
  /// Asset Library
  let assetLibrary: AssetLibrary?
  
  /// Markers
  let markers: [Marker]?
  let markerMap: [String : Marker]?
  
  /// Return all marker names, in order, or an empty list if none are specified
  public var markerNames: [String] {
    guard let markers = markers else { return [] }
    return markers.map { $0.name }
  }
  
  enum CodingKeys : String, CodingKey {
    case version = "v"
    case type = "ddd"
    case startFrame = "ip"
    case endFrame = "op"
    case framerate = "fr"
    case width = "w"
    case height = "h"
    case layers = "layers"
    case glyphs = "chars"
    case fonts = "fonts"
    case assetLibrary = "assets"
    case markers = "markers"
  }
  
  required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Animation.CodingKeys.self)
    self.version = try container.decode(String.self, forKey: .version)
    self.type = try container.decodeIfPresent(CoordinateSpace.self, forKey: .type) ?? .type2d
    self.startFrame = try container.decode(AnimationFrameTime.self, forKey: .startFrame)
    self.endFrame = try container.decode(AnimationFrameTime.self, forKey: .endFrame)
    self.framerate = try container.decode(Double.self, forKey: .framerate)
    self.width = try container.decode(Int.self, forKey: .width)
    self.height = try container.decode(Int.self, forKey: .height)
    self.layers = try container.decode([LayerModel].self, ofFamily: LayerType.self, forKey: .layers)
    self.glyphs = try container.decodeIfPresent([Glyph].self, forKey: .glyphs)
    self.fonts = try container.decodeIfPresent(FontList.self, forKey: .fonts)
    self.assetLibrary = try container.decodeIfPresent(AssetLibrary.self, forKey: .assetLibrary)
    self.markers = try container.decodeIfPresent([Marker].self, forKey: .markers)
    
    if let markers = markers {
      var markerMap: [String : Marker] = [:]
      for marker in markers {
        markerMap[marker.name] = marker
      }
      self.markerMap = markerMap
    } else {
      self.markerMap = nil
    }
  }
  
  init(dictionary: [String : Any]) throws {
    self.version = try dictionary.valueFor(key: CodingKeys.version.rawValue)
    if let typeRawValue = dictionary[CodingKeys.type.rawValue] as? Int,
       let type = CoordinateSpace(rawValue: typeRawValue) {
      self.type = type
    } else {
      self.type = .type2d
    }
    self.startFrame = try dictionary.valueFor(key: CodingKeys.startFrame.rawValue)
    self.endFrame = try dictionary.valueFor(key: CodingKeys.endFrame.rawValue)
    self.framerate = try dictionary.valueFor(key: CodingKeys.framerate.rawValue)
    self.width = try dictionary.valueFor(key: CodingKeys.width.rawValue)
    self.height = try dictionary.valueFor(key: CodingKeys.height.rawValue)
    let layerDictionaries: [[String: Any]] = try dictionary.valueFor(key: CodingKeys.layers.rawValue)
    self.layers = try [LayerModel].fromDictionaries(layerDictionaries)
    if let glyphDictionaries = dictionary[CodingKeys.glyphs.rawValue] as? [[String: Any]] {
      self.glyphs = try glyphDictionaries.map({ try Glyph(dictionary: $0) })
    } else {
      self.glyphs = nil
    }
    if let fontsDictionary = dictionary[CodingKeys.fonts.rawValue] as? [String: Any] {
      self.fonts = try FontList(dictionary: fontsDictionary)
    } else {
      self.fonts = nil
    }
    if let assetLibraryDictionaries = dictionary[CodingKeys.assetLibrary.rawValue] as? [[String: Any]] {
      self.assetLibrary = try AssetLibrary(value: assetLibraryDictionaries)
    } else {
      self.assetLibrary = nil
    }
    if let markerDictionaries = dictionary[CodingKeys.markers.rawValue] as? [[String: Any]] {
      let markers = try markerDictionaries.map({ try Marker(dictionary: $0) })
      var markerMap: [String : Marker] = [:]
      for marker in markers {
        markerMap[marker.name] = marker
      }
      self.markers = markers
      self.markerMap = markerMap
    } else {
      self.markers = nil
      self.markerMap = nil
    }
  }
  
}
