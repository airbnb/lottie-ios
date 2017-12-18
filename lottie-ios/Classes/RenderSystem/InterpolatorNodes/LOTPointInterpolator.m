//
//  LOTPointInterpolator.m
//  Lottie
//
//  Created by brandon_withrow on 7/12/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTPointInterpolator.h"
#import "CGGeometry+LOTAdditions.h"

@implementation LOTPointInterpolator

- (CGPoint)pointValueForFrame:(NSNumber *)frame {
  CGFloat progress = [self progressForFrame:frame];
  CGPoint returnPoint;
  if (progress == 0) {
    returnPoint = self.leadingKeyframe.pointValue;
  } else if (progress == 1) {
    returnPoint = self.trailingKeyframe.pointValue;
  } else if (!CGPointEqualToPoint(self.leadingKeyframe.spatialOutTangent, CGPointZero) ||
             !CGPointEqualToPoint(self.trailingKeyframe.spatialInTangent, CGPointZero)) {
    // Spatial Bezier path
    CGPoint outTan = LOT_PointAddedToPoint(self.leadingKeyframe.pointValue, self.leadingKeyframe.spatialOutTangent);
    CGPoint inTan = LOT_PointAddedToPoint(self.trailingKeyframe.pointValue, self.trailingKeyframe.spatialInTangent);
    returnPoint = LOT_PointInCubicCurve(self.leadingKeyframe.pointValue, outTan, inTan, self.trailingKeyframe.pointValue, progress);
  } else {
    returnPoint = LOT_PointInLine(self.leadingKeyframe.pointValue, self.trailingKeyframe.pointValue, progress);
  }
  if (self.hasValueOverride) {
    return self.pointCallback.callback(self.leadingKeyframe.keyframeTime.floatValue, self.trailingKeyframe.keyframeTime.floatValue, self.leadingKeyframe.pointValue, self.trailingKeyframe.pointValue, returnPoint, progress, frame.floatValue);
  }
  return returnPoint;
}

- (BOOL)hasValueOverride {
  return self.pointCallback != nil;
}

- (void)setValueCallback:(LOTValueCallback *)valueCallback {
  NSAssert(([valueCallback isKindOfClass:[LOTPointValueCallback class]]), @"Point Interpolator set with incorrect callback type. Expected LOTPointValueCallback");
  self.pointCallback = (LOTPointValueCallback*)valueCallback;
}

- (id)keyframeDataForValue:(id)value {
  if ([value isKindOfClass:[NSValue class]]) {
    CGPoint pointValue = [(NSValue *)value CGPointValue];
    return @[@(pointValue.x), @(pointValue.y)];
  }
  return nil;
}

@end
