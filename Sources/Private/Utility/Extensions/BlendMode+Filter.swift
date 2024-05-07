//
//  File.swift
//
//
//  Created by Denis Koryttsev on 10.05.2022.
//

extension BlendMode {
  /// The Core Image filter name for this `BlendMode`, that can be applied to a `CALayer`'s `compositingFilter`.
  /// Supported compositing filters are defined here: https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/uid/TP30000136-SW71
  var filterName: String? {
    switch self {
    case .normal: nil
    case .multiply: "multiplyBlendMode"
    case .screen: "screenBlendMode"
    case .overlay: "overlayBlendMode"
    case .darken: "darkenBlendMode"
    case .lighten: "lightenBlendMode"
    case .colorDodge: "colorDodgeBlendMode"
    case .colorBurn: "colorBurnBlendMode"
    case .hardLight: "hardLightBlendMode"
    case .softLight: "softLightBlendMode"
    case .difference: "differenceBlendMode"
    case .exclusion: "exclusionBlendMode"
    case .hue: "hueBlendMode"
    case .saturation: "saturationBlendMode"
    case .color: "colorBlendMode"
    case .luminosity: "luminosityBlendMode"
    }
  }
}
