//
//  LAShape.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShape.h"
#import "LAShapeItem.h"

@implementation LAShape

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{@"shapeItems" : @"it"};
}

+ (NSValueTransformer *)shapeItemsJSONTransformer {
  // tell Mantle to populate diaAttributes property with an array of MDAttribute objects
  return [MTLJSONAdapter arrayTransformerWithModelClass:[LAShapeItem class]];
}

- (NSArray *)paths {
  if (!self.shapeItems) {
    return @[];
  }
  NSMutableArray *paths = [NSMutableArray array];
  
  for (LAShapeItem *item in self.shapeItems) {
    if ([item.itemType isEqualToString:LAShapeItemType.Path]) {
      [paths addObject:item];
    }
  }
  
  return paths;
}

- (NSArray *)strokes {
  if (!self.shapeItems) {
    return @[];
  }
  NSMutableArray *strokes = [NSMutableArray array];
  
  for (LAShapeItem *item in self.shapeItems) {
    if ([item.itemType isEqualToString:LAShapeItemType.Stroke]) {
      [strokes addObject:item];
    }
  }
  
  return strokes;
}

- (NSArray *)fills {
  if (!self.shapeItems) {
    return @[];
  }
  NSMutableArray *fills = [NSMutableArray array];
  
  for (LAShapeItem *item in self.shapeItems) {
    if ([item.itemType isEqualToString:LAShapeItemType.Fill]) {
      [fills addObject:item];
    }
  }
  
  return fills;
}

- (NSArray *)transforms {
  if (!self.shapeItems) {
    return @[];
  }
  NSMutableArray *transforms = [NSMutableArray array];
  
  for (LAShapeItem *item in self.shapeItems) {
    if ([item.itemType isEqualToString:LAShapeItemType.Transform]) {
      [transforms addObject:item];
    }
  }
  
  return transforms;
}

@end
