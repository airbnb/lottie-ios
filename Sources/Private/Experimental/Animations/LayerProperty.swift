// Created by Cal Stephens on 1/11/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - LayerProperty

/// A strongly typed value that can be used as the `keyPath` of a `CAAnimation`
///
/// Supported key paths and their expected value types are described
/// at https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/AnimatableProperties/AnimatableProperties.html#//apple_ref/doc/uid/TP40004514-CH11-SW1
/// and https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/Key-ValueCodingExtensions/Key-ValueCodingExtensions.html
struct LayerProperty<ValueRepresentation> {
  /// The `CALayer` KVC key path that this value should be assigned to
  let caLayerKeypath: String

  /// A description of how this property can be customized dynamically
  /// at runtime using `AnimationView.setValueProvider(_:keypath:)`
  let customizableProperty: CustomizableProperty<ValueRepresentation>?
}

// MARK: - CustomizableProperty

/// A description of how a `CALayer` property can be customized dynamically
/// at runtime using `AnimationView.setValueProvider(_:keypath:)`
struct CustomizableProperty<ValueRepresentation> {
  /// The name that `AnimationKeypath`s can use to refer to this property
  ///  - When building an animation for this property that will be applied
  ///    to a specific layer, this `name` is appended to the end of that
  ///    layer's `AnimationKeypath`. The combined keypath is used to query
  ///    the `ValueProviderStore`.
  let name: [PropertyName]

  /// A closure that coverts the type-erased value of an `AnyValueProvider`
  /// to the strongly-typed representation used by this property, if possible.
  let conversion: (Any) -> ValueRepresentation?
}

// MARK: - PropertyName

/// The name of a customizable property that can be used in an `AnimationKeypath`
///  - These values should be shared between the two rendering engines,
///    since they form the public API of the `AnimationKeypath` system.
enum PropertyName: String {
  case color = "Color"
}

// MARK: CALayer properties

extension LayerProperty {
  static var position: LayerProperty<CGPoint> {
    .init(
      caLayerKeypath: "transform.translation",
      customizableProperty: nil /* currently unsupported */)
  }

  static var positionX: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.translation.x",
      customizableProperty: nil /* currently unsupported */)
  }

  static var positionY: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.translation.y",
      customizableProperty: nil /* currently unsupported */)
  }

  static var scale: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.scale",
      customizableProperty: nil /* currently unsupported */)
  }

  static var scaleX: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.scale.x",
      customizableProperty: nil /* currently unsupported */)
  }

  static var scaleY: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.scale.y",
      customizableProperty: nil /* currently unsupported */)
  }

  static var rotation: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.rotation",
      customizableProperty: nil /* currently unsupported */)
  }

  static var rotationY: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.rotation.y",
      customizableProperty: nil /* currently unsupported */)
  }

  static var anchorPoint: LayerProperty<CGPoint> {
    .init(
      caLayerKeypath: #keyPath(CALayer.anchorPoint),
      customizableProperty: nil /* currently unsupported */)
  }

  static var opacity: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: #keyPath(CALayer.opacity),
      customizableProperty: nil /* currently unsupported */)
  }
}

// MARK: CAShapeLayer properties

extension LayerProperty {
  static var path: LayerProperty<CGPath> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.path),
      customizableProperty: nil /* currently unsupported */)
  }

  static var fillColor: LayerProperty<CGColor> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.fillColor),
      customizableProperty: .color)
  }

  static var lineWidth: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.lineWidth),
      customizableProperty: nil /* currently unsupported */)
  }

  static var lineDashPhase: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.lineDashPhase),
      customizableProperty: nil /* currently unsupported */)
  }

  static var strokeColor: LayerProperty<CGColor> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.strokeColor),
      customizableProperty: .color)
  }

  static var strokeStart: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.strokeStart),
      customizableProperty: nil /* currently unsupported */)
  }

  static var strokeEnd: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.strokeEnd),
      customizableProperty: nil /* currently unsupported */)
  }
}

// MARK: CAGradientLayer properties

extension LayerProperty {
  static var colors: LayerProperty<[CGColor]> {
    .init(
      caLayerKeypath: #keyPath(CAGradientLayer.colors),
      customizableProperty: nil /* currently unsupported */)
  }

  static var locations: LayerProperty<[CGFloat]> {
    .init(
      caLayerKeypath: #keyPath(CAGradientLayer.locations),
      customizableProperty: nil /* currently unsupported */)
  }

  static var startPoint: LayerProperty<CGPoint> {
    .init(
      caLayerKeypath: #keyPath(CAGradientLayer.startPoint),
      customizableProperty: nil /* currently unsupported */)
  }

  static var endPoint: LayerProperty<CGPoint> {
    .init(
      caLayerKeypath: #keyPath(CAGradientLayer.endPoint),
      customizableProperty: nil /* currently unsupported */)
  }
}

// MARK: - CustomizableProperty types

extension CustomizableProperty {
  static var color: CustomizableProperty<CGColor> {
    .init(
      name: [.color],
      conversion: { typeErasedValue in
        guard let color = typeErasedValue as? Color else {
          return nil
        }

        return .rgba(CGFloat(color.r), CGFloat(color.g), CGFloat(color.b), CGFloat(color.a))
      })
  }
}
