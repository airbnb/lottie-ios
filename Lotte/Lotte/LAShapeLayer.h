//
//  LAShapeLayer.h
//  Lotte
//
//  Created by brandon_withrow on 8/15/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface LAShapeLayer : CALayer

// Animatable
@property(nullable) CGPathRef path;
@property(nullable) CGColorRef fillColor;
@property(nullable) CGColorRef strokeColor;
@property CGFloat lineWidth;
@property CGFloat strokeStart;
@property CGFloat strokeEnd;
@property CGFloat strokeOffset;
@property CGFloat strokeOpacity;
@property CGFloat fillOpacity;

//Static
@property(nullable, copy) NSArray<NSNumber *> *lineDashPattern;
@property(copy) NSString *lineCap;
@property(copy) NSString *lineJoin;

@end
