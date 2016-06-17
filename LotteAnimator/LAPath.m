//
//  LABezierPath.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAPath.h"

@implementation LAPath

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{@"points" : @"v",
           @"inTangents" : @"i",
           @"outTangents" : @"o"};
}

- (UIBezierPath *)bezierPath:(BOOL)closedPath {
  if (!self.points.count) {
    return nil;
  }
  UIBezierPath *path = [UIBezierPath bezierPath];
  
  [path moveToPoint:[self _vertexAtIndex:0]];
  for (int i = 1; i < self.points.count; i ++) {
    [path addCurveToPoint:[self _vertexAtIndex:i] controlPoint1:[self _outTangentAtIndex:i - 1] controlPoint2:[self _inTangentAtIndex:i]];
  }
  
  if (closedPath) {
    [path addCurveToPoint:[self _vertexAtIndex:0] controlPoint1:[self _outTangentAtIndex:self.points.count - 1] controlPoint2:[self _inTangentAtIndex:0]];
    [path closePath];
  }

  return path;
}

- (CGPoint)_vertexAtIndex:(NSInteger)idx {
  NSArray *pointArray = self.points[idx];
  return CGPointMake([pointArray[0] floatValue], [pointArray[1] floatValue]);
}

- (CGPoint)_outTangentAtIndex:(NSInteger)idx {
  NSArray *outArray = self.outTangents[idx];
  CGPoint vertex = [self _vertexAtIndex:idx];
  return CGPointMake([outArray[0] floatValue] + vertex.x, [outArray[1] floatValue] + vertex.y);
}

- (CGPoint)_inTangentAtIndex:(NSInteger)idx {
  NSArray *inArray = self.inTangents[idx];
  CGPoint vertex = [self _vertexAtIndex:idx];
  return CGPointMake([inArray[0] floatValue] + vertex.x, [inArray[1] floatValue] + vertex.y);
}
@end
