//
//  CompatibleGradientValueProvider.swift
//  LottieLibraryIOS
//
//  Created by DongYi on 2020/8/25.
//  Copyright © 2020 Airbnb. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit


@objc
public final class CompatibleGradientValueProvider : NSObject {

  /// Returns a [Color] for a CGFloat(Frame Time).
  public typealias ColorsValueBlock = (CGFloat) -> [Color]
  /// Returns a [Double](Color locations) for a CGFloat(Frame Time).
  public typealias ColorLocationsBlock = (CGFloat) -> [Double]
  
  /// The colors values of the provider.
  public var colors: [Color] {
      didSet {
        valueProvider.colors = colors
      }
  }
  
  /// The color location values of the provider.
  public var locations: [Double] {
      didSet {
        valueProvider.locations = locations
      }
  }
  
  /// Initializes with a block provider.
  public init(block: @escaping ColorsValueBlock,
              locations: ColorLocationsBlock? = nil) {
    self.colors = [Color(r:0, g:0, b:0, a:0)];
    self.locations = [0];
    self.valueProvider = GradientValueProvider(block: block, locations: locations);
  }
  
  /// Initializes with an array of colors.
    @objc
  public init(colors: [UIColor],
              locations: [Double] = []) {
    self.colors = [Color(r:0, g:0, b:0, a:0)];
    self.locations = [0];
        var lotColors:[Color] = [Color]();
        lotColors.reserveCapacity(colors.count)
        for (_,value) in colors.enumerated() {
            lotColors.append(value.lottieColorValue);
        }
    self.valueProvider = GradientValueProvider(lotColors, locations: locations);
  }
  
  // MARK: ValueProvider Protocol
  
  public var valueType: Any.Type {
      return [Double].self
  }
  @objc
  public func hasUpdate(frame: CGFloat) -> Bool {
    return valueProvider.hasUpdate(frame: frame)
  }
  @objc
  public func value(frame: CGFloat) -> Any {
    return valueProvider.value(frame: frame)
  }
  
  // MARK: Private
  
  private func value(from colors: [Color], locations: [Double]) -> [Double] {
      
      var colorValues = [Double]()
      var alphaValues = [Double]()
      var shouldAddAlphaValues = false
      
      for i in 0..<colors.count {
          
          if colors[i].a < 1 { shouldAddAlphaValues = true }
          
          let location = locations.count > i ? locations[i] :
              (Double(i) / Double(colors.count - 1))
          
          colorValues.append(location)
          colorValues.append(colors[i].r)
          colorValues.append(colors[i].g)
          colorValues.append(colors[i].b)
          
          alphaValues.append(location)
          alphaValues.append(colors[i].a)
      }
      
      return colorValues + (shouldAddAlphaValues ? alphaValues : [])
  }
    
   public var valueProvider : GradientValueProvider
}
#endif
