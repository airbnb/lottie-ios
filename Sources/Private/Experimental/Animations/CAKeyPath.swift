// Created by Cal Stephens on 1/11/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - CAKeyPath

/// A strongly typed value that can be used as the `keyPath` of a `CAAnimation`
struct CAKeyPath<ValueRepresentation> {
  let name: String

  init(_ name: String) {
    self.name = name
  }
}

/// Supported key paths and their expected value types are described
/// at https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/AnimatableProperties/AnimatableProperties.html#//apple_ref/doc/uid/TP40004514-CH11-SW1
/// and https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/Key-ValueCodingExtensions/Key-ValueCodingExtensions.html
extension CAKeyPath {
  static var position: CAKeyPath<CGPoint> { .init("transform.translation") }
  static var positionX: CAKeyPath<CGFloat> { .init("transform.translation.y") }
  static var positionY: CAKeyPath<CGFloat> { .init("transform.translation.x") }
  static var scale: CAKeyPath<CGFloat> { .init("transform.scale") }
  static var scaleX: CAKeyPath<CGFloat> { .init("transform.scale.x") }
  static var scaleY: CAKeyPath<CGFloat> { .init("transform.scale.y") }
  static var rotation: CAKeyPath<CGFloat> { .init("transform.rotation") }

  static var anchorPoint: CAKeyPath<CGPoint> { .init(#keyPath(CALayer.anchorPoint)) }
  static var opacity: CAKeyPath<CGFloat> { .init(#keyPath(CALayer.opacity)) }

  static var path: CAKeyPath<CGPath> { .init(#keyPath(CAShapeLayer.path)) }
  static var fillColor: CAKeyPath<CGColor> { .init(#keyPath(CAShapeLayer.fillColor)) }
  static var lineWidth: CAKeyPath<CGFloat> { .init(#keyPath(CAShapeLayer.lineWidth)) }
  static var strokeColor: CAKeyPath<CGColor> { .init(#keyPath(CAShapeLayer.strokeColor)) }
  static var strokeStart: CAKeyPath<CGFloat> { .init(#keyPath(CAShapeLayer.strokeStart)) }
  static var strokeEnd: CAKeyPath<CGFloat> { .init(#keyPath(CAShapeLayer.strokeEnd)) }

  static var colors: CAKeyPath<[CGColor]> { .init(#keyPath(CAGradientLayer.colors)) }
  static var locations: CAKeyPath<[CGFloat]> { .init(#keyPath(CAGradientLayer.locations)) }
  static var startPoint: CAKeyPath<CGPoint> { .init(#keyPath(CAGradientLayer.startPoint)) }
  static var endPoint: CAKeyPath<CGPoint> { .init(#keyPath(CAGradientLayer.endPoint)) }
}
