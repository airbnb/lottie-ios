//
//  AnimationContainer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/24/19.
//

import Foundation
import QuartzCore

// MARK: - AnimationContainer

/**
 The base animation container.

 This layer holds a single composition container and allows for animation of
 the currentFrame property.
 */
final class AnimationContainer: CALayer {

  // MARK: Lifecycle

  init(
    animation: Animation,
    imageProvider: AnimationImageProvider,
    textProvider: AnimationTextProvider,
    fontProvider: AnimationFontProvider)
  {
    layerImageProvider = LayerImageProvider(imageProvider: imageProvider, assets: animation.assetLibrary?.imageAssets)
    layerTextProvider = LayerTextProvider(textProvider: textProvider)
    layerFontProvider = LayerFontProvider(fontProvider: fontProvider)
    animationLayers = []
    super.init()
    bounds = animation.bounds
    let layers = animation.layers.initializeCompositionLayers(
      assetLibrary: animation.assetLibrary,
      layerImageProvider: layerImageProvider,
      textProvider: textProvider,
      fontProvider: fontProvider,
      frameRate: CGFloat(animation.framerate))

    var imageLayers = [ImageCompositionLayer]()
    var textLayers = [TextCompositionLayer]()

    var mattedLayer: CompositionLayer? = nil

    for layer in layers.reversed() {
      layer.bounds = bounds
      animationLayers.append(layer)
      if let imageLayer = layer as? ImageCompositionLayer {
        imageLayers.append(imageLayer)
      }
      if let textLayer = layer as? TextCompositionLayer {
        textLayers.append(textLayer)
      }
      if let matte = mattedLayer {
        /// The previous layer requires this layer to be its matte
        matte.matteLayer = layer
        mattedLayer = nil
        continue
      }
      if
        let matte = layer.matteType,
        matte == .add || matte == .invert
      {
        /// We have a layer that requires a matte.
        mattedLayer = layer
      }
      addSublayer(layer)
    }

    layerImageProvider.addImageLayers(imageLayers)
    layerImageProvider.reloadImages()
    layerTextProvider.addTextLayers(textLayers)
    layerTextProvider.reloadTexts()
    layerFontProvider.addTextLayers(textLayers)
    layerFontProvider.reloadTexts()
    setNeedsDisplay()
  }

  /// For CAAnimation Use
  public override init(layer: Any) {
    animationLayers = []
    layerImageProvider = LayerImageProvider(imageProvider: BlankImageProvider(), assets: nil)
    layerTextProvider = LayerTextProvider(textProvider: DefaultTextProvider())
    layerFontProvider = LayerFontProvider(fontProvider: DefaultFontProvider())
    super.init(layer: layer)

    guard let animationLayer = layer as? AnimationContainer else { return }

    currentFrame = animationLayer.currentFrame

  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var respectAnimationFrameRate: Bool = false

  // MARK: CALayer Animations

  override public class func needsDisplay(forKey key: String) -> Bool {
    if key == "currentFrame" {
      return true
    }
    return super.needsDisplay(forKey: key)
  }

  override public func action(forKey event: String) -> CAAction? {
    if event == "currentFrame" {
      let animation = CABasicAnimation(keyPath: event)
      animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
      animation.fromValue = presentation()?.currentFrame
      return animation
    }
    return super.action(forKey: event)
  }

  public override func display() {
    guard Thread.isMainThread else { return }
    var newFrame: CGFloat
    if
      let animationKeys = animationKeys(),
      !animationKeys.isEmpty
    {
      newFrame = presentation()?.currentFrame ?? currentFrame
    } else {
      // We ignore the presentation's frame if there's no animation in the layer.
      newFrame = currentFrame
    }
    if respectAnimationFrameRate {
      newFrame = floor(newFrame)
    }
    animationLayers.forEach( { $0.displayWithFrame(frame: newFrame, forceUpdates: false) })
  }

  // MARK: Internal

  /// The animatable Current Frame Property
  @NSManaged var currentFrame: CGFloat

  var animationLayers: ContiguousArray<CompositionLayer>

  var imageProvider: AnimationImageProvider {
    get {
      layerImageProvider.imageProvider
    }
    set {
      layerImageProvider.imageProvider = newValue
    }
  }

  var renderScale: CGFloat = 1 {
    didSet {
      animationLayers.forEach({ $0.renderScale = renderScale })
    }
  }

  var textProvider: AnimationTextProvider {
    get { layerTextProvider.textProvider }
    set { layerTextProvider.textProvider = newValue }
  }

  var fontProvider: AnimationFontProvider {
    get { layerFontProvider.fontProvider }
    set { layerFontProvider.fontProvider = newValue }
  }

  func reloadImages() {
    layerImageProvider.reloadImages()
  }

  /// Forces the view to update its drawing.
  func forceDisplayUpdate() {
    animationLayers.forEach( { $0.displayWithFrame(frame: currentFrame, forceUpdates: true) })
  }

  func logHierarchyKeypaths() {
    print("Lottie: Logging Animation Keypaths")
    animationLayers.forEach({ $0.logKeypaths(for: nil) })
  }

  func setValueProvider(_ valueProvider: AnyValueProvider, keypath: AnimationKeypath) {
    for layer in animationLayers {
      if let foundProperties = layer.nodeProperties(for: keypath) {
        for property in foundProperties {
          property.setProvider(provider: valueProvider)
        }
        layer.displayWithFrame(frame: presentation()?.currentFrame ?? currentFrame, forceUpdates: true)
      }
    }
  }

  func getValue(for keypath: AnimationKeypath, atFrame: CGFloat?) -> Any? {
    for layer in animationLayers {
      if
        let foundProperties = layer.nodeProperties(for: keypath),
        let first = foundProperties.first
      {
        return first.valueProvider.value(frame: atFrame ?? currentFrame)
      }
    }
    return nil
  }

  func layer(for keypath: AnimationKeypath) -> CALayer? {
    for layer in animationLayers {
      if let foundLayer = layer.layer(for: keypath) {
        return foundLayer
      }
    }
    return nil
  }

  func animatorNodes(for keypath: AnimationKeypath) -> [AnimatorNode]? {
    var results = [AnimatorNode]()
    for layer in animationLayers {
      if let nodes = layer.animatorNodes(for: keypath) {
        results.append(contentsOf: nodes)
      }
    }
    if results.count == 0 {
      return nil
    }
    return results
  }

  // MARK: Fileprivate

  fileprivate let layerImageProvider: LayerImageProvider
  fileprivate let layerTextProvider: LayerTextProvider
  fileprivate let layerFontProvider: LayerFontProvider
}

// MARK: - BlankImageProvider

fileprivate class BlankImageProvider: AnimationImageProvider {
  func imageForAsset(asset _: ImageAsset) -> CGImage? {
    nil
  }
}
