//
//  AnimationPublic.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/5/19.
//

import CoreGraphics
import Foundation

extension Animation {

  /// A closure for an Animation download. The closure is passed `nil` if there was an error.
  public typealias DownloadClosure = (Animation?) -> Void

  /// The duration in seconds of the animation.
  public var duration: TimeInterval {
    Double(endFrame - startFrame) / framerate
  }

  /// The natural bounds in points of the animation.
  public var bounds: CGRect {
    CGRect(x: 0, y: 0, width: width, height: height)
  }

  /// The natural size in points of the animation.
  public var size: CGSize {
    CGSize(width: width, height: height)
  }

  // MARK: Animation (Loading)

  /// Loads an animation model from a bundle by its name. Returns `nil` if an animation is not found.
  ///
  /// - Parameter name: The name of the json file without the json extension. EG "StarAnimation"
  /// - Parameter bundle: The bundle in which the animation is located. Defaults to `Bundle.main`
  /// - Parameter subdirectory: A subdirectory in the bundle in which the animation is located. Optional.
  /// - Parameter animationCache: A cache for holding loaded animations. Optional.
  ///
  /// - Returns: Deserialized `Animation`. Optional.
  public static func named(
    _ name: String,
    bundle: Bundle = Bundle.main,
    subdirectory: String? = nil,
    animationCache: AnimationCacheProvider? = nil)
    -> Animation?
  {
    /// Create a cache key for the animation.
    let cacheKey = bundle.bundlePath + (subdirectory ?? "") + "/" + name

    /// Check cache for animation
    if
      let animationCache = animationCache,
      let animation = animationCache.animation(forKey: cacheKey)
    {
      /// If found, return the animation.
      return animation
    }

    do {
      /// Decode animation.
      guard let json = try bundle.getAnimationData(name, subdirectory: subdirectory) else {
        return nil
      }
      let animation = try Animation.from(data: json)
      animationCache?.setAnimation(animation, forKey: cacheKey)
      return animation
    } catch {
      /// Decoding error.
      LottieLogger.shared.warn("Error when decoding animation \"\(name)\": \(error)")
      return nil
    }
  }

  /// Loads an animation from a specific filepath.
  /// - Parameter filepath: The absolute filepath of the animation to load. EG "/User/Me/starAnimation.json"
  /// - Parameter animationCache: A cache for holding loaded animations. Optional.
  ///
  /// - Returns: Deserialized `Animation`. Optional.
  public static func filepath(
    _ filepath: String,
    animationCache: AnimationCacheProvider? = nil)
    -> Animation?
  {

    /// Check cache for animation
    if
      let animationCache = animationCache,
      let animation = animationCache.animation(forKey: filepath)
    {
      return animation
    }

    do {
      /// Decode the animation.
      let json = try Data(contentsOf: URL(fileURLWithPath: filepath))
      let animation = try Animation.from(data: json)
      animationCache?.setAnimation(animation, forKey: filepath)
      return animation
    } catch {
      /// Decoding Error.
      return nil
    }
  }

  ///    Loads an animation model from the asset catalog by its name. Returns `nil` if an animation is not found.
  ///    - Parameter name: The name of the json file in the asset catalog. EG "StarAnimation"
  ///    - Parameter bundle: The bundle in which the animation is located. Defaults to `Bundle.main`
  ///    - Parameter animationCache: A cache for holding loaded animations. Optional.
  ///    - Returns: Deserialized `Animation`. Optional.
  public static func asset(
    _ name: String,
    bundle: Bundle = Bundle.main,
    animationCache: AnimationCacheProvider? = nil)
    -> Animation?
  {
    /// Create a cache key for the animation.
    let cacheKey = bundle.bundlePath + "/" + name

    /// Check cache for animation
    if
      let animationCache = animationCache,
      let animation = animationCache.animation(forKey: cacheKey)
    {
      /// If found, return the animation.
      return animation
    }

    /// Load jsonData from Asset
    guard let json = Data.jsonData(from: name, in: bundle) else {
      return nil
    }

    do {
      /// Decode animation.
      let animation = try Animation.from(data: json)
      animationCache?.setAnimation(animation, forKey: cacheKey)
      return animation
    } catch {
      /// Decoding error.
      return nil
    }
  }

  /// Loads a Lottie animation from a `Data` object containing a JSON animation.
  ///
  /// - Parameter data: The object to load the animation from.
  /// - Parameter strategy: How the data should be decoded. Defaults to using the strategy set in `LottieConfiguration.shared`.
  /// - Returns: Deserialized `Animation`. Optional.
  ///
  public static func from(
    data: Data,
    strategy: DecodingStrategy = LottieConfiguration.shared.decodingStrategy) throws
    -> Animation
  {
    switch strategy {
    case .codable:
      return try JSONDecoder().decode(Animation.self, from: data)
    case .dictionaryBased:
      let json = try JSONSerialization.jsonObject(with: data)
      guard let dict = json as? [String: Any] else {
        throw InitializableError.invalidInput
      }
      return try Animation(dictionary: dict)
    }
  }

  /// Loads a Lottie animation asynchronously from the URL.
  ///
  /// - Parameter url: The url to load the animation from.
  /// - Parameter closure: A closure to be called when the animation has loaded.
  /// - Parameter animationCache: A cache for holding loaded animations.
  ///
  public static func loadedFrom(
    url: URL,
    closure: @escaping Animation.DownloadClosure,
    animationCache: AnimationCacheProvider?)
  {

    if let animationCache = animationCache, let animation = animationCache.animation(forKey: url.absoluteString) {
      closure(animation)
    } else {
      let task = URLSession.shared.dataTask(with: url) { data, _, error in
        guard error == nil, let jsonData = data else {
          DispatchQueue.main.async {
            closure(nil)
          }
          return
        }
        do {
          let animation = try Animation.from(data: jsonData)
          DispatchQueue.main.async {
            animationCache?.setAnimation(animation, forKey: url.absoluteString)
            closure(animation)
          }
        } catch {
          DispatchQueue.main.async {
            closure(nil)
          }
        }

      }
      task.resume()
    }
  }

  // MARK: Animation (Helpers)

  /// Markers are a way to describe a point in time by a key name.
  ///
  /// Markers are encoded into animation JSON. By using markers a designer can mark
  /// playback points for a developer to use without having to worry about keeping
  /// track of animation frames. If the animation file is updated, the developer
  /// does not need to update playback code.
  ///
  /// Returns the Progress Time for the marker named. Returns nil if no marker found.
  public func progressTime(forMarker named: String) -> AnimationProgressTime? {
    guard let markers = markerMap, let marker = markers[named] else {
      return nil
    }
    return progressTime(forFrame: marker.frameTime)
  }

  /// Markers are a way to describe a point in time by a key name.
  ///
  /// Markers are encoded into animation JSON. By using markers a designer can mark
  /// playback points for a developer to use without having to worry about keeping
  /// track of animation frames. If the animation file is updated, the developer
  /// does not need to update playback code.
  ///
  /// Returns the Frame Time for the marker named. Returns nil if no marker found.
  public func frameTime(forMarker named: String) -> AnimationFrameTime? {
    guard let markers = markerMap, let marker = markers[named] else {
      return nil
    }
    return marker.frameTime
  }

  /// Converts Frame Time (Seconds * Framerate) into Progress Time
  /// (optionally clamped to between 0 and 1).
  public func progressTime(
    forFrame frameTime: AnimationFrameTime,
    clamped: Bool = true)
    -> AnimationProgressTime
  {
    let progressTime = ((frameTime - startFrame) / (endFrame - startFrame))

    if clamped {
      return progressTime.clamp(0, 1)
    } else {
      return progressTime
    }
  }

  /// Converts Progress Time (0 to 1) into Frame Time (Seconds * Framerate)
  public func frameTime(forProgress progressTime: AnimationProgressTime) -> AnimationFrameTime {
    ((endFrame - startFrame) * progressTime) + startFrame
  }

  /// Converts Frame Time (Seconds * Framerate) into Time (Seconds)
  public func time(forFrame frameTime: AnimationFrameTime) -> TimeInterval {
    Double(frameTime - startFrame) / framerate
  }

  /// Converts Time (Seconds) into Frame Time (Seconds * Framerate)
  public func frameTime(forTime time: TimeInterval) -> AnimationFrameTime {
    CGFloat(time * framerate) + startFrame
  }
}
