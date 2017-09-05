//
//  LOTAnimationView
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTRadialGradientLayer.h"
#import "CGGeometry+LOTAdditions.h"

@implementation LOTRadialGradientLayer

@dynamic isRadial;
@dynamic startPoint;
@dynamic endPoint;
@dynamic colors;
@dynamic locations;

+ (BOOL)needsDisplayForKey:(NSString *)key {
  if ([key isEqualToString:@"startPoint"] ||
      [key isEqualToString:@"endPoint"] ||
      [key isEqualToString:@"colors"] ||
      [key isEqualToString:@"locations"] ||
      [key isEqualToString:@"isRadial"]) {
    return YES;
  }
  return [super needsDisplayForKey:key];
}

- (id)actionForKey:(NSString *)key {  
  if ([key isEqualToString:@"startPoint"] ||
      [key isEqualToString:@"endPoint"] ||
      [key isEqualToString:@"colors"] ||
      [key isEqualToString:@"locations"] ||
      [key isEqualToString:@"isRadial"]) {
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:key];
    theAnimation.fromValue = [self.presentationLayer valueForKey:key];
    return theAnimation;
  }
  return [super actionForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
  NSInteger numberOfLocations = self.locations.count;
  NSInteger numbOfComponents = 0;
  CGColorSpaceRef colorSpace = NULL;
  
  if (self.colors.count) {
    CGColorRef colorRef = (__bridge CGColorRef)[self.colors objectAtIndex:0];
    numbOfComponents = CGColorGetNumberOfComponents(colorRef);
    colorSpace = CGColorGetColorSpace(colorRef);
  }
  
  CGPoint origin = self.startPoint;
  CGFloat radius = LOT_PointDistanceFromPoint(self.startPoint, self.endPoint);
  
  CGFloat gradientLocations[numberOfLocations];
  CGFloat gradientComponents[numberOfLocations * numbOfComponents];
  
  for (NSInteger locationIndex = 0; locationIndex < numberOfLocations; locationIndex++) {
    
    gradientLocations[locationIndex] = [self.locations[locationIndex] floatValue];
    const CGFloat *colorComponents = CGColorGetComponents((__bridge CGColorRef)self.colors[locationIndex]);
    
    for (NSInteger componentIndex = 0; componentIndex < numbOfComponents; componentIndex++) {
      gradientComponents[numbOfComponents * locationIndex + componentIndex] = colorComponents[componentIndex];
    }
  }
  
  CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradientComponents, gradientLocations, numberOfLocations);
  
  if (self.isRadial) {
    CGContextDrawRadialGradient(ctx, gradient, origin, 0, origin, radius, kCGGradientDrawsAfterEndLocation);
  } else {
    CGContextDrawLinearGradient(ctx, gradient, self.startPoint, self.endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
  }
  
  CGGradientRelease(gradient);
}

@end
