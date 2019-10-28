//
//  ColorsValueProvider.swift
//  lottie-swift
//
//  Created by Enrique Bermúdez on 10/27/19.
//

import Foundation
import CoreGraphics

/// A `ValueProvider` that returns a Gradient Color Value.
public final class ColorsValueProvider: AnyValueProvider {
    
    /// Returns a [Color] for a CGFloat(Frame Time).
    public typealias ColorsValueBlock = (CGFloat) -> [Color]
    /// Returns a [Double](Color locations) for a CGFloat(Frame Time).
    public typealias ColorLocationsBlock = (CGFloat) -> [Double]
    
    /// The colors values of the provider.
    public var colors: [Color] {
        didSet {
            hasUpdate = true
        }
    }
    
    /// The color location values of the provider.
    public var locations: [Double] {
        didSet {
            hasUpdate = true
        }
    }
    
    /// Initializes with a block provider.
    public init(block: @escaping ColorsValueBlock,
                locations: ColorLocationsBlock? = nil) {
        self.block = block
        self.locationsBlock = locations
        self.colors = []
        self.locations = []
    }
    
    /// Initializes with an array of colors.
    public init(_ colors: [Color],
                locations: [Double] = []) {
        self.colors = colors
        self.locations = locations
        hasUpdate = true
    }
    
    // MARK: ValueProvider Protocol
    
    public var valueType: Any.Type {
        return [Double].self
    }
    
    public func hasUpdate(frame: CGFloat) -> Bool {
        if block != nil || locationsBlock != nil {
            return true
        }
        return hasUpdate
    }
    
    public func value(frame: CGFloat) -> Any {
        hasUpdate = false
        let newColors: [Color]
        if let block = block {
            newColors = block(frame)
        } else {
            newColors = colors
        }
        
        let newLocations: [Double]
        if let colorLocationsBlock = locationsBlock {
            newLocations = colorLocationsBlock(frame)
        } else {
            newLocations = locations
        }
        
        return self.value(from: newColors, locations: newLocations)
    }
    
    // MARK: Private
    
    func value(from colors: [Color], locations: [Double]) -> [Double] {
        
        var colorValues = [Double]()
        var alphaValues = [Double]()
        var shouldAddAlphaValues = false
        
        for i in 0..<colors.count {

            if colors[i].a < 1 { shouldAddAlphaValues = true }
            
            let location = locations.count > i ? locations[i] :
                calculateLocation(withStartValue: locations.last ?? 0.0,
                                  endValue: 1.0,
                                  elements: colors.count - locations.count,
                                  position:  i - locations.count,
                                  skipStartValue: locations.count > 0)

            colorValues.append(location)
            colorValues.append(colors[i].r)
            colorValues.append(colors[i].g)
            colorValues.append(colors[i].b)
            
            alphaValues.append(location)
            alphaValues.append(colors[i].a)
        }
        
        return colorValues + (shouldAddAlphaValues ? alphaValues : [])
    }
    
    private func calculateLocation(withStartValue startValue: Double,
                                   endValue: Double,
                                   elements: Int,
                                   position: Int,
                                   skipStartValue: Bool) -> Double{
        
        guard startValue != endValue else { return 1.0 }
        
        let strides = (elements - 1) + (skipStartValue ? 1 : 0)
        let index = position + (skipStartValue ? 1 : 0)
        
        return  Array(stride(from: startValue,
                             through: endValue,
                             by: (endValue - startValue) / Double(strides)))[index]
    }
    
    private var hasUpdate: Bool = true
    
    private var block: ColorsValueBlock?
    private var locationsBlock: ColorLocationsBlock?
}
