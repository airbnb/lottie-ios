// Created by Cal Stephens on 12/14/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - ShapeLayer

/// The CALayer type responsible for rendering `ShapeLayerModel`s
final class ShapeLayer: CALayer {

  // MARK: Lifecycle

  init(shapeLayer: ShapeLayerModel) {
    self.shapeLayer = shapeLayer
    super.init()

    for item in shapeLayer.items {
      // TODO: Can items other than `Group`s appear at the top level?
      // If so, how does that work?
      if let group = item as? Group {
        let sublayer = ShapeItemLayer(items: group.items)
        addSublayer(sublayer)
      }
    }
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Called by CoreAnimation to create a shadow copy of this layer
  /// More details: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
  override init(layer: Any) {
    guard let layer = layer as? Self else {
      fatalError("\(Self.self).init(layer:) incorrectly called with \(type(of: layer))")
    }

    shapeLayer = layer.shapeLayer
    super.init(layer: layer)
  }

  // MARK: Internal

  override func layoutSublayers() {
    super.layoutSublayers()

    for sublayer in sublayers ?? [] {
      sublayer.fillBoundsOfSuperlayer()
    }
  }

  // MARK: Private

  private let shapeLayer: ShapeLayerModel

}

// MARK: AnimationLayer

extension ShapeLayer: AnimationLayer {
  func setupAnimations(context: LayerAnimationContext) {
    addAnimation(
      for: .position,
      keyframes: shapeLayer.transform.position,
      value: \.pointValue,
      context: context)

    addAnimation(
      for: .scaleX,
      keyframes: shapeLayer.transform.scale,
      value: { scale in
        // Lottie animation files express scale as a numerical percentage value
        // (e.g. 50%, 100%, 200%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.5, 1.0, 2.0).
        CGFloat(scale.x) / 100
      },
      context: context)

    addAnimation(
      for: .scaleY,
      keyframes: shapeLayer.transform.scale,
      value: { scale in
        // Lottie animation files express scale as a numerical percentage value
        // (e.g. 50%, 100%, 200%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.5, 1.0, 2.0).
        CGFloat(scale.y) / 100
      },
      context: context)

    addAnimation(
      for: .anchorPoint,
      keyframes: shapeLayer.transform.anchorPoint,
      value: { absoluteAnchorPoint in
        guard bounds.width > 0, bounds.height > 0 else {
          assertionFailure("Size must be non-zero before an animation can be played")
          return .zero
        }

        // Lottie animation files express anchorPoint as an absolute point value,
        // so we have to divide by the width/height of this layer to get the
        // relative decimal values expected by Core Animation.
        return CGPoint(
          x: CGFloat(absoluteAnchorPoint.x) / bounds.width,
          y: CGFloat(absoluteAnchorPoint.y) / bounds.height)
      },
      context: context)

    addAnimation(
      for: .opacity,
      keyframes: shapeLayer.transform.opacity,
      value: {
        // Lottie animation files express opacity as a numerical percentage value
        // (e.g. 0%, 50%, 100%) so we divide by 100 to get the decimal values
        // expected by Core Animation (e.g. 0.0, 0.5, 1.0).
        $0.cgFloatValue / 100
      },
      context: context)
  }
}

// MARK: - ShapeLayerModel + LayerConstructing

extension ShapeLayerModel: LayerConstructing {
  func makeLayer() -> AnimationLayer {
    ShapeLayer(shapeLayer: self)
  }
}
