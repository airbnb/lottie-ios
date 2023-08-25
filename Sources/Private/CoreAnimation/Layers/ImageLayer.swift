// Created by Cal Stephens on 1/10/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ImageLayer

/// The `CALayer` type responsible for rendering `ImageLayerModel`s
final class ImageLayer: BaseCompositionLayer {

  // MARK: Lifecycle

  init(
    imageLayer: ImageLayerModel,
    context: LayerContext)
  {
    self.imageLayer = imageLayer
    super.init(layerModel: imageLayer)
    setupImage(context: context)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Called by CoreAnimation to create a shadow copy of this layer
  /// More details: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
  override init(layer: Any) {
    guard let typedLayer = layer as? Self else {
      fatalError("\(Self.self).init(layer:) incorrectly called with \(type(of: layer))")
    }

    imageLayer = typedLayer.imageLayer
    super.init(layer: typedLayer)
  }

  // MARK: Internal

  func setupImage(context: LayerContext) {
    guard let imageAsset = context.animation.assetLibrary?.imageAssets[imageLayer.referenceID] else { return }

    if
      #available(iOS 13.0, tvOS 13.0, macOS 10.15, *),
      let asyncImageProvider = context.imageProvider as? AsyncAnimationImageProvider
    {
      setupImageAsynchronously(imageAsset, using: asyncImageProvider)
    }

    else {
      setupImageSynchronously(imageAsset, using: context.imageProvider)
    }
  }

  @available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
  private func setupImageAsynchronously(_ asset: ImageAsset, using asyncImageProvider: AsyncAnimationImageProvider) {
    let placeholder = asyncImageProvider.placeholder(for: asset)
    switch placeholder {
    case .layer(let placeholderLayer):
      contentsLayer.addSublayer(placeholderLayer)
    case .none:
      break
    }

    Task {
      let image = try? await asyncImageProvider.image(for: asset)

      await MainActor.run {
        imageAsset = asset

        // bug: this works in a simple animation
        // but in at least one complex animation I tested
        // the layout is wrong and I can't fix it
        contentsLayer.contents = image
        setNeedsLayout()

        switch placeholder {
        case .layer(let placeholderLayer):
          placeholderLayer.removeFromSuperlayer()
        case .none:
          break
        }
      }
    }
    
  }

  private func setupImageSynchronously(_ asset: ImageAsset, using syncImageProvider: AnimationImageProvider) {
    guard let image = syncImageProvider.imageForAsset(asset: asset) else {
      imageAsset = nil
      contentsLayer.contents = nil
      return
    }

    imageAsset = asset
    contentsLayer.contents = image
    setNeedsLayout()
  }

  // MARK: Private

  private let imageLayer: ImageLayerModel
  private var imageAsset: ImageAsset?

}

// MARK: CustomLayoutLayer

extension ImageLayer: CustomLayoutLayer {
  func layout(superlayerBounds: CGRect) {
    anchorPoint = .zero

    guard let imageAsset = imageAsset else {
      bounds = superlayerBounds
      return
    }

    // Image layers specifically need to use the size of the image itself
    bounds = CGRect(
      x: superlayerBounds.origin.x,
      y: superlayerBounds.origin.y,
      width: CGFloat(imageAsset.width),
      height: CGFloat(imageAsset.height))
  }
}
