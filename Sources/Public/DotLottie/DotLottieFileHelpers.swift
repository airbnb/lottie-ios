//
//  DotLottieFileHelpers.swift
//  Lottie
//
//  Created by Evandro Hoffmann on 20/10/22.
//

import Foundation

extension DotLottieFile {

  // MARK: Public

  /// A closure for an DotLottieFile download. The closure is passed `nil` if there was an error.
  public typealias DotLottieLoadClosure = (Result<DotLottieFile, Error>) -> Void

  // MARK: DotLottie file (Loading)

  /// Loads a DotLottie model from a bundle by its name. Returns `nil` if a file is not found.
  ///
  /// - Parameter name: The name of the lottie file without the lottie extension. EG "StarAnimation"
  /// - Parameter bundle: The bundle in which the lottie is located. Defaults to `Bundle.main`
  /// - Parameter subdirectory: A subdirectory in the bundle in which the lottie is located. Optional.
  /// - Parameter closure: A closure to be called when the file has loaded.
  /// - Parameter dotLottieCache: A cache for holding loaded lotties. Defaults to `LRUDotLottieCache.sharedCache`. Optional.
  public static func named(
    _ name: String,
    bundle: Bundle = Bundle.main,
    subdirectory: String? = nil,
    closure: @escaping DotLottieLoadClosure,
    dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache)
  {
    DispatchQueue.global().async {
      /// Create a cache key for the lottie.
      let cacheKey = bundle.bundlePath + (subdirectory ?? "") + "/" + name

      /// Check cache for lottie
      if
        let dotLottieCache = dotLottieCache,
        let lottie = dotLottieCache.file(forKey: cacheKey)
      {
        DispatchQueue.main.async {
          /// If found, return the lottie.
          closure(.success(lottie))
        }
      }

      do {
        /// Decode animation.
        guard let data = try bundle.dotLottieData(name, subdirectory: subdirectory) else {
          DispatchQueue.main.async {
            closure(.failure(DotLottieError.invalidData))
          }
          return
        }
        let lottie = try DotLottieFile.from(data: data, filename: name)
        dotLottieCache?.setFile(lottie, forKey: cacheKey)
        DispatchQueue.main.async {
          closure(.success(lottie))
        }
      } catch {
        /// Decoding error.
        LottieLogger.shared.warn("Error when decoding lottie \"\(name)\": \(error)")
        DispatchQueue.main.async {
          closure(.failure(error))
        }
      }
    }
  }

  /// Loads an DotLottie from a specific filepath.
  /// - Parameter filepath: The absolute filepath of the lottie to load. EG "/User/Me/starAnimation.lottie"
  /// - Parameter closure: A closure to be called when the file has loaded.
  /// - Parameter dotLottieCache: A cache for holding loaded lotties. Defaults to `LRUDotLottieCache.sharedCache`. Optional.
  public static func filepath(
    _ filepath: String,
    closure: @escaping DotLottieLoadClosure,
    dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache)
  {
    DispatchQueue.global().async {
      /// Check cache for lottie
      if
        let dotLottieCache = dotLottieCache,
        let lottie = dotLottieCache.file(forKey: filepath)
      {
        DispatchQueue.main.async {
          closure(.success(lottie))
        }
      }

      do {
        /// Decode the lottie.
        let url = URL(fileURLWithPath: filepath)
        let data = try Data(contentsOf: url)
        let lottie = try DotLottieFile.from(data: data, filename: url.deletingPathExtension().lastPathComponent)
        dotLottieCache?.setFile(lottie, forKey: filepath)
        DispatchQueue.main.async {
          closure(.success(lottie))
        }
      } catch {
        /// Decoding Error.
        DispatchQueue.main.async {
          closure(.failure(error))
        }
      }
    }
  }

  ///    Loads a DotLottie model from the asset catalog by its name. Returns `nil` if a lottie is not found.
  ///    - Parameter name: The name of the lottie file in the asset catalog. EG "StarAnimation"
  ///    - Parameter bundle: The bundle in which the lottie is located. Defaults to `Bundle.main`
  ///    - Parameter closure: A closure to be called when the file has loaded.
  ///    - Parameter dotLottieCache: A cache for holding loaded lottie files. Defaults to `LRUDotLottieCache.sharedCache` Optional.
  public static func asset(
    _ name: String,
    bundle: Bundle = Bundle.main,
    closure: @escaping DotLottieLoadClosure,
    dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache)
  {
    DispatchQueue.global().async {
      /// Create a cache key for the lottie.
      let cacheKey = bundle.bundlePath + "/" + name

      /// Check cache for lottie
      if
        let dotLottieCache = dotLottieCache,
        let lottie = dotLottieCache.file(forKey: cacheKey)
      {
        /// If found, return the lottie.
        DispatchQueue.main.async {
          closure(.success(lottie))
        }
      }

      /// Load data from Asset
      guard let data = Data.jsonData(from: name, in: bundle) else {
        DispatchQueue.main.async {
          closure(.failure(DotLottieError.invalidData))
        }
        return
      }

      do {
        /// Decode lottie.
        let lottie = try DotLottieFile.from(data: data, filename: name)
        dotLottieCache?.setFile(lottie, forKey: cacheKey)
        DispatchQueue.main.async {
          closure(.success(lottie))
        }
      } catch {
        /// Decoding error.
        DispatchQueue.main.async {
          closure(.failure(error))
        }
      }
    }
  }

  /// Loads a DotLottie animation from a `Data` object containing a compressed .lottie file.
  ///
  /// - Parameter data: The object to load the file from.
  /// - Parameter filename: The name of the file.
  /// - Returns: Deserialized `DotLottie`. Optional.
  ///
  public static func from(data: Data, filename: String) throws
    -> DotLottieFile
  {
    try DotLottieFile(data: data, filename: filename)
  }

  /// Loads a DotLottie animation asynchronously from the URL.
  ///
  /// - Parameter url: The url to load the animation from.
  /// - Parameter closure: A closure to be called when the animation has loaded.
  /// - Parameter animationCache: A cache for holding loaded animations. Defaults to `LRUAnimationCache.sharedCache`. Optional.
  ///
  public static func loadedFrom(
    url: URL,
    session: URLSession = .shared,
    closure: @escaping DotLottieLoadClosure,
    dotLottieCache: DotLottieCacheProvider? = DotLottieCache.sharedCache)
  {
    if let dotLottieCache = dotLottieCache, let lottie = dotLottieCache.file(forKey: url.absoluteString) {
      closure(.success(lottie))
    } else {
      let task = session.dataTask(with: url) { data, _, error in
        guard error == nil, let data = data else {
          DispatchQueue.main.async {
            closure(.failure(DotLottieError.invalidData))
          }
          return
        }
        do {
          let lottie = try DotLottieFile.from(data: data, filename: url.deletingPathExtension().lastPathComponent)
          DispatchQueue.main.async {
            dotLottieCache?.setFile(lottie, forKey: url.absoluteString)
            closure(.success(lottie))
          }
        } catch {
          DispatchQueue.main.async {
            closure(.failure(error))
          }
        }
      }
      task.resume()
    }
  }

  /// Returns animation with id
  /// - Parameter id: id to animation. Specified in .lottie file manifest. Optional
  /// Defaults to first animation
  /// - Returns: LottieAnimation with id. Optional
  public func animation(for id: String? = nil) -> LottieAnimation? {
    if let id = id {
      return animations.first(where: { $0.dotLottieConfiguration?.id == id })
    } else {
      return animations.first
    }
  }

  // MARK: Internal

  /// Returns the list of `DotLottieAnimation` in the file
  var dotLottieAnimations: [DotLottieAnimation] {
    manifest?.animations.map({
      var animation = $0
      animation.animationUrl = animationsUrl.appendingPathComponent("\($0.id).json")
      return animation
    }) ?? []
  }

}
