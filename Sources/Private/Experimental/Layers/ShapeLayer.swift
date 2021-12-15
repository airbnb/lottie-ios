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
        value: { CGFloat($0.x) / 100 },
        context: context),

      shapeLayer.transform.scale.caKeyframes(
        animating: .scaleY,
        value: { CGFloat($0.y) / 100 },
        context: context),

      shapeLayer.transform.anchorPoint.caKeyframes(
        animating: .anchorPoint,
        value: { vector in
          CGPoint(
            x: CGFloat(vector.x) / bounds.width,
            y: CGFloat(vector.y) / bounds.height)
        },
        context: context),

      shapeLayer.transform.opacity.caKeyframes(
        animating: .opacity,
        value: { $0.cgFloatValue / 100 },
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
