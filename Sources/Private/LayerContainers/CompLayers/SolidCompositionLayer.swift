//
//  SolidCompositionLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation
import QuartzCore

final class SolidCompositionLayer: CompositionLayer {

  // MARK: Lifecycle

  init(solid: SolidLayerModel) {
    let components = solid.colorHex.hexColorComponents()
    colorProperty =
      NodeProperty(provider: SingleValueProvider(Color(
        r: Double(components.red),
        g: Double(components.green),
        b: Double(components.blue),
        a: 1)))

    super.init(layer: solid, size: .zero)
    solidShape.path = CGPath(rect: CGRect(x: 0, y: 0, width: solid.width, height: solid.height), transform: nil)
    contentsLayer.addSublayer(solidShape)
  }

  override init(layer: Any) {
    /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
    guard let layer = layer as? SolidCompositionLayer else {
      fatalError("init(layer:) Wrong Layer Class")
    }
    colorProperty = layer.colorProperty
    super.init(layer: layer)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  let colorProperty: NodeProperty<Color>?
  let solidShape = CAShapeLayer()

  override var keypathProperties: [String: AnyNodeProperty] {
    guard let colorProperty = colorProperty else { return super.keypathProperties }
    return ["Color" : colorProperty]
  }

  override func displayContentsWithFrame(frame: CGFloat, forceUpdates _: Bool) {
    guard let colorProperty = colorProperty else { return }
    colorProperty.update(frame: frame)
    solidShape.fillColor = colorProperty.value.cgColorValue
  }
}
