// Created by Lan Xu on 2024/6/8.
// Copyright © 2024 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - LayerEffectNode

protocol LayerEffectNode {
  var propertyMap: NodePropertyMap { get }

  func applyEffect(to layer: CALayer)
}

extension LayerEffectNode {

  func updateWithFrame(layer: CALayer, frame: CGFloat) {
    for property in propertyMap.properties {
      if property.needsUpdate(frame: frame) {
        property.update(frame: frame)
      }
    }
    applyEffect(to: layer)
  }

}
