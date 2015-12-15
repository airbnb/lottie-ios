//
//  LALayer.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LALayer.h"

@implementation LALayer

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
  // model_property_name : json_field_name
  return @{
           @"layerName" : @"layerName",
           @"layerID" : @"ind",
           @"width" : @"width",
           @"height" : @"height",
           @"rotation" : @"",
           @"positionArray" : @"ks.p",
           @"anchorPointArray" : @"ks.a",
           @"scaleArray" : @"ks.s",
           @"opacity" : @"ks.o",
           @"color" : @"color",
           @"masks" : @"masksProperties"
           };
}

+ (NSValueTransformer *)masksJSONTransformer {
  return [MTLJSONAdapter arrayTransformerWithModelClass:[LAMask class]];
}

- (UIColor *)bgColor {
  if (!self.color) {
    return [UIColor clearColor];
  }
  NSString *hexString = [self.color copy];
  hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
  
  return [UIColor colorWithHexString:hexString];
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
  CGPoint uikitAnchorPoint = CGPointMake(aeAnchorPoint.x / self.size.width,
                                         aeAnchorPoint.y / self.size.height);
  return uikitAnchorPoint;
}

- (CGSize)size {
  if (!self.width && !self.height) {
    return CGSizeZero;
  }
  return CGSizeMake(self.width.floatValue, self.height.floatValue);
}

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

- (CGRect)frameRect {
  return CGRectMake(self.position.x, self.position.y, self.size.width, self.size.height);
}

- (CGAffineTransform)transform {
  return CGAffineTransformRotate(CGAffineTransformMakeScale(self.scale.width, self.scale.height), DegreesToRadians(self.rotation ? self.rotation.floatValue : 0.f));
}

@end
