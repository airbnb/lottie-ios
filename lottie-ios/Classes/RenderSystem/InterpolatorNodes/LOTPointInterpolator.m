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
  if (progress == 0) {
    return self.leadingKeyframe.pointValue;
  }
  if (progress == 1) {
    return self.trailingKeyframe.pointValue;
  }
  if (!CGPointEqualToPoint(self.leadingKeyframe.spatialOutTangent, CGPointZero) &&
      !CGPointEqualToPoint(self.trailingKeyframe.spatialInTangent, CGPointZero)) {
    // Spatial Bezier path
    CGPoint outTan = LOT_PointAddedToPoint(self.leadingKeyframe.pointValue, self.leadingKeyframe.spatialOutTangent);
    CGPoint inTan = LOT_PointAddedToPoint(self.trailingKeyframe.pointValue, self.trailingKeyframe.spatialInTangent);
    return LOT_PointInCubicCurve(self.leadingKeyframe.pointValue, outTan, inTan, self.trailingKeyframe.pointValue, progress);
  }
  return LOT_PointInLine(self.leadingKeyframe.pointValue, self.trailingKeyframe.pointValue, progress);
}

- (id)keyframeDataForValue:(id)value {
  if ([value isKindOfClass:[NSValue class]]) {
    CGPoint pointValue = [(NSValue *)value CGPointValue];
    return @[@(pointValue.x), @(pointValue.y)];
  }
  return nil;
}

@end
