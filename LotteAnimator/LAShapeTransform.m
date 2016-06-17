//
//  LAShapeTransform.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeTransform.h"

@implementation LAShapeTransform

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{@"itemType" : @"ty",
           @"positionArray" : @"p",
           @"anchorPointArray" : @"a",
           @"scaleArray" : @"s",
           @"rotation" : @"r",
           @"opacity" : @"o"};
}

- (CGPoint)position {
  if (!self.positionArray) {
    return CGPointZero;
  }
  CGPoint aePosition = CGPointMake([self.positionArray[0] floatValue], [self.positionArray[1] floatValue]);
  if (self.anchorPointArray) {
    aePosition.x -= [self.anchorPointArray[0] floatValue];
    aePosition.y -= [self.anchorPointArray[1] floatValue];
  }
  return aePosition;
}

- (CGPoint)anchorPoint {
  if (!self.anchorPointArray) {
    return CGPointZero;
  }
  CGPoint aeAnchorPoint = CGPointMake([self.anchorPointArray[0] floatValue], [self.anchorPointArray[1] floatValue]);
//  CGPoint uikitAnchorPoint = CGPointMake(aeAnchorPoint.x / self.size.width,
//                                         aeAnchorPoint.y / self.size.height);
  // TODO Figure out this crazy thing
  return aeAnchorPoint;
}

// TODO Permanently Unwrap these arrays for efficency
- (CGSize)scale {
  if (!self.scaleArray) {
    return CGSizeZero;
  }
  return CGSizeMake([self.scaleArray[0] floatValue] / 100.f, [self.scaleArray[1] floatValue] / 100.f);
}

- (CGFloat)alpha {
  if (!self.opacity) {
    return 1;
  }
  return self.opacity.floatValue / 100.f;
}

- (CGAffineTransform)transform {
  CGAffineTransform translate = CGAffineTransformMakeTranslation(self.position.x, self.position.y);
  CGAffineTransform scale = CGAffineTransformScale(translate, self.scale.width, self.scale.height);
  CGAffineTransform rotate = CGAffineTransformRotate(scale, DegreesToRadians(self.rotation ? self.rotation.floatValue : 0.f));
  return rotate;
}

@end
