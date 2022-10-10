// Created by Cal Stephens on 1/11/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import QuartzCore

// MARK: - LayerProperty

/// A strongly typed value that can be used as the `keyPath` of a `CAAnimation`
///
/// Supported key paths and their expected value types are described
/// at https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/AnimatableProperties/AnimatableProperties.html#//apple_ref/doc/uid/TP40004514-CH11-SW1
/// and https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/Key-ValueCodingExtensions/Key-ValueCodingExtensions.html
struct LayerProperty<ValueRepresentation: Equatable> {
  /// The `CALayer` KVC key path that this value should be assigned to
  let caLayerKeypath: String

  /// The default value of this property on a `CALayer`
  ///  - If the keyframe values are just equal to the default value,
  ///    then we can improve performance a bit by just not creating
  ///    a CAAnimation (since it would be redundant).
  let defaultValue: ValueRepresentation?

  /// A description of how this property can be customized dynamically
  /// at runtime using `AnimationView.setValueProvider(_:keypath:)`
  let customizableProperty: CustomizableProperty<ValueRepresentation>?
}

// MARK: - CustomizableProperty

/// A description of how a `CALayer` property can be customized dynamically
/// at runtime using `LottieAnimationView.setValueProvider(_:keypath:)`
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
      defaultValue: CGPoint(x: 0, y: 0),
      customizableProperty: nil /* currently unsupported */ )
  }

  static var positionX: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.translation.x",
      defaultValue: 0,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var positionY: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.translation.y",
      defaultValue: 0,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var scale: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.scale",
      defaultValue: 1,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var scaleX: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.scale.x",
      defaultValue: 1,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var scaleY: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.scale.y",
      defaultValue: 1,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var rotation: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.rotation",
      defaultValue: 0,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var rotationY: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: "transform.rotation.y",
      defaultValue: 0,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var anchorPoint: LayerProperty<CGPoint> {
    .init(
      caLayerKeypath: #keyPath(CALayer.anchorPoint),
      // This is intentionally not `GGPoint(x: 0.5, y: 0.5)` (the actual default)
      // to opt `anchorPoint` out of the KVC `setValue` flow, which causes issues.
      defaultValue: nil,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var opacity: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: #keyPath(CALayer.opacity),
      defaultValue: 1,
      customizableProperty: nil /* currently unsupported */ )
  }
}

// MARK: CAShapeLayer properties

extension LayerProperty {
  static var path: LayerProperty<CGPath> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.path),
      defaultValue: nil,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var fillColor: LayerProperty<CGColor> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.fillColor),
      defaultValue: nil,
      customizableProperty: .color)
  }

  static var lineWidth: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.lineWidth),
      defaultValue: 1,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var lineDashPhase: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.lineDashPhase),
      defaultValue: 0,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var strokeColor: LayerProperty<CGColor> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.strokeColor),
      defaultValue: nil,
      customizableProperty: .color)
  }

  static var strokeStart: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.strokeStart),
      defaultValue: 0,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var strokeEnd: LayerProperty<CGFloat> {
    .init(
      caLayerKeypath: #keyPath(CAShapeLayer.strokeEnd),
      defaultValue: 1,
      customizableProperty: nil /* currently unsupported */ )
  }
}

// MARK: CAGradientLayer properties

extension LayerProperty {
  static var colors: LayerProperty<[CGColor]> {
    .init(
      caLayerKeypath: #keyPath(CAGradientLayer.colors),
      defaultValue: nil,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var locations: LayerProperty<[CGFloat]> {
    .init(
      caLayerKeypath: #keyPath(CAGradientLayer.locations),
      defaultValue: nil,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var startPoint: LayerProperty<CGPoint> {
    .init(
      caLayerKeypath: #keyPath(CAGradientLayer.startPoint),
      defaultValue: nil,
      customizableProperty: nil /* currently unsupported */ )
  }

  static var endPoint: LayerProperty<CGPoint> {
    .init(
      caLayerKeypath: #keyPath(CAGradientLayer.endPoint),
      defaultValue: nil,
      customizableProperty: nil /* currently unsupported */ )
  }
}

// MARK: - CustomizableProperty types

extension CustomizableProperty {
  static var color: CustomizableProperty<CGColor> {
    .init(
      name: [.color],
      conversion: { typeErasedValue in
        guard let color = typeErasedValue as? LottieColor else {
          return nil
        }

        return .rgba(CGFloat(color.r), CGFloat(color.g), CGFloat(color.b), CGFloat(color.a))
      })
  }
}
