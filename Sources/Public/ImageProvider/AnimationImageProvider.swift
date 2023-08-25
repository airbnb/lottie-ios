//
//  LottieImageProvider.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import CoreGraphics
import Foundation
import QuartzCore

// MARK: - AnimationImageProvider

/// Image provider is a protocol that is used to supply images to `LottieAnimationView`.
///
/// Some animations require a reference to an image. The image provider loads and
/// provides those images to the `LottieAnimationView`.  Lottie includes a couple of
/// prebuilt Image Providers that supply images from a Bundle, or from a FilePath.
///
/// Additionally custom Image Providers can be made to load images from a URL,
/// or to Cache images.
///
/// Note: The original `AnimationImageProvider` API is synchronous.
/// To load images asynchronously, conform to `AsyncAnimationImageProvider` instead,
/// or convert your `AnimationImageProvider` into an `AsyncAnimationImageProvider`
/// by using `myImageProvider.asyncImageProvider(...)`.
public protocol AnimationImageProvider {
  /// Synchronously loads the `CGImage` for the given asset.
  ///  - To load the image asynchronously, conform to `AsyncAnimationImageProvider` instead.
  func imageForAsset(asset: ImageAsset) -> CGImage?
}

extension AnimationImageProvider {
  /// Creates an `AsyncAnimationImageProvider` for this synchronous `AnimationImageProvider`
  /// - Parameter makePlaceholder: A closure that synchronously returns a placeholder
  ///   to display while the given asset is loading.
  @available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
  public func asyncImageProvider(
    makePlaceholder: @escaping (ImageAsset) -> LottieImagePlaceholder?)
    -> AsyncImageProviderWrapper<Self>
  {
    AsyncImageProviderWrapper(
      synchronousImageProvider: self,
      makePlaceholder: makePlaceholder)
  }
}

// MARK: - AnimationImageProvider

/// Image provider is a protocol that is used to supply images to `LottieAnimationView`.
///
/// Some animations require a reference to an image. The image provider loads and
/// provides those images to the `LottieAnimationView`.  Lottie includes a couple of
/// prebuilt Image Providers that supply images from a Bundle, or from a FilePath.
///
/// Additionally custom Image Providers can be made to load images from a URL,
/// or to Cache images.
@available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
public protocol AsyncAnimationImageProvider: AnimationImageProvider {
  /// Asynchronously loads the `CGImage` for the given asset.
  func image(for asset: ImageAsset) async throws -> CGImage?

  /// Synchronously returns a placeholder to display while the given asset is loading via the `image(for:)` method.
  func placeholder(for asset: ImageAsset) -> LottieImagePlaceholder?
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
extension AsyncAnimationImageProvider {
  @available(*, deprecated, message: "When using `AsyncAnimationImageProvider`, call the async `image(for:)` method.")
  public func imageForAsset(asset: ImageAsset) -> CGImage? { nil }
}

public enum LottieImagePlaceholder {
  /// The given CALayer is displayed while the image is being loaded
  case layer(CALayer)

  /// The given `CGColor` is displayed while the image is being loaded
  public static func color(_ cgColor: CGColor) -> LottieImagePlaceholder {
    let solidLayer = CALayer()
    solidLayer.backgroundColor = cgColor
    return .layer(solidLayer)
  }

  /// The given `CGImage` is displayed while the image is being loaded
  public static func image(_ cgImage: CGImage) -> LottieImagePlaceholder {
    let imageLayer = CALayer()
    imageLayer.contents = cgImage
    return .layer(imageLayer)
  }
}

// MARK: - AsyncImageProviderWrapper

/// A wrapper that converts the given `AnimationImageProvider` into a `AsyncAnimationImageProvider`.
@available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
public struct AsyncImageProviderWrapper<ImageProvider: AnimationImageProvider>: AsyncAnimationImageProvider {

  init(
    synchronousImageProvider: ImageProvider,
    makePlaceholder: @escaping (ImageAsset) -> LottieImagePlaceholder?)
  {
    self.synchronousImageProvider = synchronousImageProvider
    self.makePlaceholder = makePlaceholder
  }

  public func image(for asset: ImageAsset) async throws -> CGImage? {
    if #available(macOS 13.0, iOS 16.0, *) {
      try await Task.sleep(for: .seconds(1))
    }

    return await withCheckedContinuation { continuation in
      Task {
        let image = synchronousImageProvider.imageForAsset(asset: asset)
        continuation.resume(returning: image)
      }
    }
  }

  public func placeholder(for asset: ImageAsset) -> LottieImagePlaceholder? {
    makePlaceholder(asset)
  }

  private let synchronousImageProvider: ImageProvider
  private let makePlaceholder: (ImageAsset) -> LottieImagePlaceholder?
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
extension AsyncImageProviderWrapper: Equatable where ImageProvider: Equatable {
  public static func ==(_ lhs: AsyncImageProviderWrapper, _ rhs: AsyncImageProviderWrapper) -> Bool {
    lhs.synchronousImageProvider == rhs.synchronousImageProvider
  }
}
