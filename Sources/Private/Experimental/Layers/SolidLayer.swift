// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - SolidLayer

final class SolidLayer: CALayer {

  // MARK: Lifecycle

  init(_ solidLayer: SolidLayerModel) {
    self.solidLayer = solidLayer
    super.init()

    // TODO: We'll of course need some way to handle
    // converting keyframes to a CA animation of some kind
    backgroundColor = solidLayer.colorHex.cgColor

    // TODO: On the model side, these fields are part of a `LayerModel` superclass.
    // We should put this somewhere where it doesn't have to be duplicated by
    // all layer types.
    transform = CATransform3D.makeTransform(
      anchor: solidLayer.transform.anchorPoint.keyframes.first!.value.pointValue,
      position: solidLayer.transform.position?.keyframes.first!.value.pointValue ?? .zero,
      scale: solidLayer.transform.scale.keyframes.first!.value.sizeValue,
      rotation: solidLayer.transform.rotation.keyframes.first!.value.cgFloatValue,
      skew: nil,
      skewAxis: nil)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private

  private let solidLayer: SolidLayerModel

}

// MARK: AnimationLayer

extension SolidLayer: AnimationLayer {
  func animations(context _: LayerAnimationContext) -> [CAPropertyAnimation] {
    [] // TODO: implement
  }
}

// MARK: - SolidLayerModel + LayerConstructing

extension SolidLayerModel: LayerConstructing {
  func makeLayer() -> AnimationLayer {
    SolidLayer(self)
  }
}
