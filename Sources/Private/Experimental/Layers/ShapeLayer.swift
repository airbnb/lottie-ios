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

    // TODO: On the model side, these fields are part of a `LayerModel` superclass.
    // We should put this somewhere where it doesn't have to be duplicated by
    // all layer types.
    transform = CATransform3D.makeTransform(
      anchor: shapeLayer.transform.anchorPoint.keyframes.first!.value.pointValue,
      position: shapeLayer.transform.position?.keyframes.first!.value.pointValue ?? .zero,
      scale: shapeLayer.transform.scale.keyframes.first!.value.sizeValue,
      rotation: shapeLayer.transform.rotation.keyframes.first!.value.cgFloatValue,
      skew: nil,
      skewAxis: nil)

    opacity = Float(shapeLayer.transform.opacity.keyframes.first!.value.value / 100)

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
  func animations(context: LayerAnimationContext) -> [CAPropertyAnimation] {
    [
      shapeLayer.transform.position?.caKeyframes(
        animating: .position,
        value: \.pointValue,
        context: context),

      shapeLayer.transform.scale.caKeyframes(
        animating: .scaleX,
        value: { scale in
          // Lottie animation files express scale as a numerical percentage value
          // (e.g. 50%, 100%, 200%) so we divide by 100 to get the decimal values
          // expected by Core Animation (e.g. 0.5, 1.0, 2.0).
          CGFloat(scale.x) / 100
        },
        context: context),

      shapeLayer.transform.scale.caKeyframes(
        animating: .scaleY,
        value: { scale in
          // Lottie animation files express scale as a numerical percentage value
          // (e.g. 50%, 100%, 200%) so we divide by 100 to get the decimal values
          // expected by Core Animation (e.g. 0.5, 1.0, 2.0).
          CGFloat(scale.y) / 100
        },
        context: context),

      shapeLayer.transform.anchorPoint.caKeyframes(
        animating: .anchorPoint,
        value: { absoluteAnchorPoint in
          // Lottie animation files express anchorPoint as an absolute point value,
          // so we have to divide by the width/height of this layer to get the
          // relative decimal values expected by Core Animation.
          CGPoint(
            x: CGFloat(absoluteAnchorPoint.x) / bounds.width,
            y: CGFloat(absoluteAnchorPoint.y) / bounds.height)
        },
        context: context),

      shapeLayer.transform.opacity.caKeyframes(
        animating: .opacity,
        value: {
          // Lottie animation files express opacity as a numerical percentage value
          // (e.g. 0%, 50%, 100%) so we divide by 100 to get the decimal values
          // expected by Core Animation (e.g. 0.0, 0.5, 1.0).
          $0.cgFloatValue / 100
        },
        context: context),
    ]
    .compactMap { $0 }
  }
}

// MARK: - ShapeLayerModel + LayerConstructing

extension ShapeLayerModel: LayerConstructing {
  func makeLayer() -> AnimationLayer {
    ShapeLayer(shapeLayer: self)
  }
}
