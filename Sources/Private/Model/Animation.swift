//
//  Animation.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/7/19.
//

import Foundation

// MARK: - CoordinateSpace

public enum CoordinateSpace: Int, Codable {
  case type2d
  case type3d
}

// MARK: - Animation

/**
 The `Animation` model is the top level model object in Lottie.

 An `Animation` holds all of the animation data backing a Lottie Animation.
 Codable, see JSON schema [here](https://github.com/airbnb/lottie-web/tree/master/docs/json).
 */
public final class Animation: Codable {

  // MARK: Lifecycle

  required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Animation.CodingKeys.self)
    version = try container.decode(String.self, forKey: .version)
    type = try container.decodeIfPresent(CoordinateSpace.self, forKey: .type) ?? .type2d
    startFrame = try container.decode(AnimationFrameTime.self, forKey: .startFrame)
    endFrame = try container.decode(AnimationFrameTime.self, forKey: .endFrame)
    framerate = try container.decode(Double.self, forKey: .framerate)
    width = try container.decode(Int.self, forKey: .width)
    height = try container.decode(Int.self, forKey: .height)
    layers = try container.decode([LayerModel].self, ofFamily: LayerType.self, forKey: .layers)
    glyphs = try container.decodeIfPresent([Glyph].self, forKey: .glyphs)
    fonts = try container.decodeIfPresent(FontList.self, forKey: .fonts)
    assetLibrary = try container.decodeIfPresent(AssetLibrary.self, forKey: .assetLibrary)
    markers = try container.decodeIfPresent([Marker].self, forKey: .markers)

    if let markers = markers {
      var markerMap: [String: Marker] = [:]
      for marker in markers {
        markerMap[marker.name] = marker
      }
      self.markerMap = markerMap
    } else {
      markerMap = nil
    }
  }

  // MARK: Public

  /// The start time of the composition in frameTime.
  public let startFrame: AnimationFrameTime

  /// The end time of the composition in frameTime.
  public let endFrame: AnimationFrameTime

  /// The frame rate of the composition.
  public let framerate: Double

  /// Return all marker names, in order, or an empty list if none are specified
  public var markerNames: [String] {
    guard let markers = markers else { return [] }
    return markers.map { $0.name }
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
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

  /// The version of the JSON Schema.
  let version: String

  /// The coordinate space of the composition.
  let type: CoordinateSpace

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
  let markerMap: [String: Marker]?
}
