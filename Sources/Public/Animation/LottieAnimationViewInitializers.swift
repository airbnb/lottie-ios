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

  // MARK: DotLottie

  /// Loads a Lottie animation from a .lottie file in the supplied bundle.
  ///
  /// - Parameter name: The string name of the lottie file with no file
  /// extension provided.
  /// - Parameter bundle: The bundle in which the file is located.
  /// Defaults to the Main bundle.
  public convenience init(
    dotLottieName name: String,
    bundle: Bundle = Bundle.main,
    dotLottieCache: DotLottieCacheProvider? = LRUDotLottieCache.sharedCache,
    configuration: LottieConfiguration = .shared)
  {
    let lottie = DotLottie.named(name, bundle: bundle, subdirectory: nil, dotLottieCache: dotLottieCache)
    self.init(dotLottie: lottie, configuration: configuration)
  }

  /// Loads a Lottie from a .lottie file in a specific path on disk.
  ///
  /// - Parameter filePath: The absolute path of the Lottie file.
  public convenience init(
    dotLottieFilePath filePath: String,
    dotLottieCache: DotLottieCacheProvider? = LRUDotLottieCache.sharedCache,
    configuration: LottieConfiguration = .shared)
  {
    let lottie = DotLottie.filepath(filePath, dotLottieCache: dotLottieCache)
    self.init(dotLottie: lottie, configuration: configuration)
  }

  /// Loads a Lottie file asynchronously from the URL
  ///
  /// - Parameter dotLottieUrl: The url to load the lottie file from.
  /// - Parameter closure: A closure to be called when the animation has loaded.
  public convenience init(
    dotLottieUrl url: URL,
    closure: @escaping LottieAnimationView.DownloadClosure,
    dotLottieCache: DotLottieCacheProvider? = LRUDotLottieCache.sharedCache,
    configuration: LottieConfiguration = .shared)
  {
    if let dotLottieCache = dotLottieCache, let lottie = dotLottieCache.file(forKey: url.absoluteString) {
      self.init(animation: lottie.animation, imageProvider: nil, configuration: configuration)
      closure(nil)
    } else {
      self.init(dotLottie: nil, configuration: configuration)
      DotLottie.loadedFrom(url: url, closure: { lottie in
        if let lottie = lottie {
          if let animation = lottie.animation {
            self.animation = animation
            self.loopMode = animation.dotLottieConfiguration?.loopMode ?? .playOnce
            self.animationSpeed = animation.dotLottieConfiguration?.speed ?? 1

            if let imageProvider = animation.dotLottieConfiguration?.imageProvider {
              self.imageProvider = imageProvider
            }

            closure(nil)
          } else {
            closure(DotLottieError.animationNotAvailable)
          }
        } else {
          closure(LottieDownloadError.downloadFailed)
        }
      }, dotLottieCache: dotLottieCache)
    }
  }

  /// Loads a Lottie from a .lottie file located in the Asset catalog of the supplied bundle.
  /// - Parameter name: The string name of the lottie file in the asset catalog.
  /// - Parameter bundle: The bundle in which the file is located.
  /// Defaults to the Main bundle.
  public convenience init(
    dotLottieAsset name: String,
    bundle: Bundle = Bundle.main,
    dotLottieCache: DotLottieCacheProvider? = LRUDotLottieCache.sharedCache,
    configuration: LottieConfiguration = .shared)
  {
    let lottie = DotLottie.asset(name, bundle: bundle, dotLottieCache: dotLottieCache)
    self.init(dotLottie: lottie, configuration: configuration)
  }

  // MARK: Public

  public typealias DownloadClosure = (Error?) -> Void

}

// MARK: - LottieDownloadError

enum LottieDownloadError: Error {
  case downloadFailed
}