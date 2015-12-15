//
//  LAShapeStroke.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeStroke.h"

@implementation LAShapeStroke

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{@"itemType" : @"ty",
           @"fillEnabled" : @"fillEnabled",
           @"colorElements" : @"c",
           @"opacity" : @"o",
           @"width" : @"w"};
}

+ (NSValueTransformer *)fillEnabledJSONTransformer {
  return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

- (CGFloat)alpha {
  if (!self.opacity) {
    return 1;
  }
  return self.opacity.floatValue / 100.f;
}

- (UIColor *)color {
  if (!self.colorElements) {
    return [UIColor clearColor];
  }
  return [UIColor colorWithRed:([self.colorElements[0] floatValue]/255.f)
                         green:([self.colorElements[1] floatValue]/255.f)
                          blue:([self.colorElements[2] floatValue]/255.f)
                         alpha:([self.colorElements[3] floatValue]/255.f)];
}

@end
