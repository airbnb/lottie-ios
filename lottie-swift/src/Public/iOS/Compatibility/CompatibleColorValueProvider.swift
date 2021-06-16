//
//  CompatibleColorValueProvider.swift
//  LottieLibraryIOS
//
//  Created by DongYi on 2020/8/25.
//  Copyright © 2020 Airbnb. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit

/// An Objective-C compatible wrapper around Lottie's AnimationKeypath
@objc
public final class CompatibleColorValueProvider : NSObject {

    public typealias ColorValueBlock = (CGFloat) -> Color
    
  public var color: Color {
    didSet {
        valueProvider.color = color
    }
  }
  
  /// Initializes with a block provider
  public init(block: @escaping ColorValueBlock) {
    self.color = Color(r:0, g:0, b:0, a:0);
    self.valueProvider = ColorValueProvider(block: block)
  }
  
  /// Initializes with a single color.
    @objc
  public init(color: UIColor) {
    self.color = Color(r:0, g:0, b:0, a:0);
    self.valueProvider = ColorValueProvider(color.lottieColorValue);
  }
  
  // MARK: ValueProvider Protocol
  
  public var valueType: Any.Type {
    return Color.self
  }
  
  public func hasUpdate(frame: CGFloat) -> Bool {
    return valueProvider.hasUpdate(frame: frame)
  }
  
  public func value(frame: CGFloat) -> Any {
    return valueProvider.value(frame: frame)
  }
    
    public var valueProvider : ColorValueProvider
}
#endif
