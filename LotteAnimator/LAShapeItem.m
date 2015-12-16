//
//  LAShapeItem.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeItem.h"

const struct LAShapeItemType LAShapeItemType = {
  .Path = @"sh",
  .Stroke = @"st",
  .Fill = @"fl",
  .Transform = @"tr",
  .Circle = @"el",
  .Rectangle = @"rc"
};

@implementation LAShapeItem

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{@"itemType" : @"ty"};
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
  if ([JSONDictionary[@"ty"] isEqual:LAShapeItemType.Path]) {
    return LAShapePath.class;
  }
  
  if ([JSONDictionary[@"ty"] isEqual:LAShapeItemType.Stroke]) {
    return LAShapeStroke.class;
  }
  
  if ([JSONDictionary[@"ty"] isEqual:LAShapeItemType.Fill]) {
    return LAShapeFill.class;
  }
  
  if ([JSONDictionary[@"ty"] isEqual:LAShapeItemType.Transform]) {
    return LAShapeTransform.class;
  }
  
  if ([JSONDictionary[@"ty"] isEqual:LAShapeItemType.Circle]) {
    return LAShapeCircle.class;
  }
  
  if ([JSONDictionary[@"ty"] isEqual:LAShapeItemType.Rectangle]) {
    return LAShapeRectangle.class;
  }
  
  return self;
}

@end
