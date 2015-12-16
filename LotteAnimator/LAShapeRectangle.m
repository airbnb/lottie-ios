//
//  LAShapeRectangle.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeRectangle.h"

@implementation LAShapeRectangle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{@"itemType" : @"ty",
           @"positionArray" : @"p",
           @"sizeArray" : @"s",
           @"rotation" : @"r"};
}

- (CGPoint)position {
  if (!self.positionArray) {
    return CGPointZero;
  }
  CGPoint aePosition = CGPointMake([self.positionArray[0] floatValue], [self.positionArray[1] floatValue]);
  
  return aePosition;
}

- (CGSize)size {
  if (!self.sizeArray) {
    return CGSizeZero;
  }
  return CGSizeMake([self.sizeArray[0] floatValue], [self.sizeArray[1] floatValue]);
}

- (UIBezierPath *)path {
  CGRect rectBounds = CGRectMake(self.size.width * -0.5, self.size.height * -0.5, self.size.width, self.size.height);
  UIBezierPath *path = [UIBezierPath bezierPathWithRect:rectBounds];
  if (self.rotation) {
    [path applyTransform:CGAffineTransformMakeRotation(DegreesToRadians(self.rotation.floatValue))];
  }
  return path;
}

@end
