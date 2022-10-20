//
//  AnimationViewInitializers.swift
//  lottie-swift-iOS
//
//  Created by Brandon Withrow on 2/6/19.
//

import Foundation

extension LottieAnimationView {

  // MARK: Lifecycle

  /// Loads a Lottie animation from a JSON file in the supplied bundle.
  ///
  /// - Parameter name: The string name of the lottie animation with no file
  /// extension provided.
  /// - Parameter bundle: The bundle in which the animation is located.
  /// Defaults to the Main bundle.
  /// - Parameter imageProvider: An image provider for the animation's image data.
  /// If none is supplied Lottie will search in the supplied bundle for images.
  public convenience init(
    name: String,
    bundle: Bundle = Bundle.main,
    imageProvider: AnimationImageProvider? = nil,
    animationCache: AnimationCacheProvider? = LRUAnimationCache.sharedCache,
    configuration: LottieConfiguration = .shared)
  {
    let animation = LottieAnimation.named(name, bundle: bundle, subdirectory: nil, animationCache: animationCache)
    let provider = imageProvider ?? BundleImageProvider(bundle: bundle, searchPath: nil)
    self.init(animation: animation, imageProvider: provider, configuration: configuration)
  }

  /// Loads a Lottie animation from a JSON file in a specific path on disk.
  ///
  /// - Parameter name: The absolute path of the Lottie Animation.
  /// - Parameter imageProvider: An image provider for the animation's image data.
  /// If none is supplied Lottie will search in the supplied filepath for images.
  public convenience init(
    filePath: String,
    imageProvider: AnimationImageProvider? = nil,
    animationCache: AnimationCacheProvider? = LRUAnimationCache.sharedCache,
    configuration: LottieConfiguration = .shared)
  {
    let animation = LottieAnimation.filepath(filePath, animationCache: animationCache)
    let provider = imageProvider ??
      FilepathImageProvider(filepath: URL(fileURLWithPath: filePath).deletingLastPathComponent().path)
    self.init(animation: animation, imageProvider: provider, configuration: configuration)
  }

  /// Loads a Lottie animation asynchronously from the URL
  ///
  /// - Parameter url: The url to load the animation from.
  /// - Parameter imageProvider: An image provider for the animation's image data.
  /// If none is supplied Lottie will search in the main bundle for images.
  /// - Parameter closure: A closure to be called when the animation has loaded.
  public convenience init(
    url: URL,
    imageProvider: AnimationImageProvider? = nil,
    closure: @escaping LottieAnimationView.DownloadClosure,
    animationCache: AnimationCacheProvider? = LRUAnimationCache.sharedCache,
    configuration: LottieConfiguration = .shared)
  {
    if let animationCache = animationCache, let animation = animationCache.animation(forKey: url.absoluteString) {
      self.init(animation: animation, imageProvider: imageProvider, configuration: configuration)
      closure(nil)
    } else {
      self.init(animation: nil, imageProvider: imageProvider, configuration: configuration)

      LottieAnimation.loadedFrom(url: url, closure: { animation in
        if let animation = animation {
          self.animation = animation
          closure(nil)
        } else {
          closure(LottieDownloadError.downloadFailed)
        }
      }, animationCache: animationCache)
    }
  }

  /// Loads a Lottie animation from a JSON file located in the Asset catalog of the supplied bundle.
  /// - Parameter name: The string name of the lottie animation in the asset catalog.
  /// - Parameter bundle: The bundle in which the animation is located.
  /// Defaults to the Main bundle.
  /// - Parameter imageProvider: An image provider for the animation's image data.
  /// If none is supplied Lottie will search in the supplied bundle for images.
  public convenience init(
    asset name: String,
    bundle: Bundle = Bundle.main,
    imageProvider: AnimationImageProvider? = nil,
    animationCache: AnimationCacheProvider? = LRUAnimationCache.sharedCache,
    configuration: LottieConfiguration = .shared)
  {
    let animation = LottieAnimation.asset(name, bundle: bundle, animationCache: animationCache)
    let provider = imageProvider ?? BundleImageProvider(bundle: bundle, searchPath: nil)
    self.init(animation: animation, imageProvider: provider, configuration: configuration)
  }

  // MARK: Public

  public typealias DownloadClosure = (Error?) -> Void

}

// MARK: - LottieDownloadError

enum LottieDownloadError: Error {
  case downloadFailed
}
