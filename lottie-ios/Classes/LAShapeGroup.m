//
//  LAShape.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeGroup.h"
#import "LAShapeFill.h"
#import "LAShapePath.h"
#import "LAShapeCircle.h"
#import "LAShapeStroke.h"
#import "LAShapeTransform.h"
#import "LAShapeRectangle.h"
#import "LAShapeTrimPath.h"

@implementation LAShapeGroup

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate compBounds:compBounds];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds {
  NSArray *itemsJSON = jsonDictionary[@"it"];
  NSMutableArray *items = [NSMutableArray array];
  for (NSDictionary *itemJSON in itemsJSON) {
    id newItem = [LAShapeGroup shapeItemWithJSON:itemJSON frameRate:frameRate compBounds:compBounds];
    if (newItem) {
      [items addObject:newItem];
    }
  }
  _items = items;
}

+ (id)shapeItemWithJSON:(NSDictionary *)itemJSON frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds {
  NSString *type = itemJSON[@"ty"];
  if ([type isEqualToString:@"gr"]) {
    LAShapeGroup *group = [[LAShapeGroup alloc] initWithJSON:itemJSON frameRate:frameRate compBounds:compBounds];
    return group;
  } else if ([type isEqualToString:@"st"]) {
    LAShapeStroke *stroke = [[LAShapeStroke alloc] initWithJSON:itemJSON frameRate:frameRate];
    return stroke;
  } else if ([type isEqualToString:@"fl"]) {
    LAShapeFill *fill = [[LAShapeFill alloc] initWithJSON:itemJSON frameRate:frameRate];
    return fill;
  } else if ([type isEqualToString:@"tr"]) {
    LAShapeTransform *transform = [[LAShapeTransform alloc] initWithJSON:itemJSON frameRate:frameRate compBounds:compBounds];
    return transform;
  } else if ([type isEqualToString:@"sh"]) {
    LAShapePath *path = [[LAShapePath alloc] initWithJSON:itemJSON frameRate:frameRate];
    return path;
  } else if ([type isEqualToString:@"el"]) {
    LAShapeCircle *circle = [[LAShapeCircle alloc] initWithJSON:itemJSON frameRate:frameRate];
    return circle;
  } else if ([type isEqualToString:@"rc"]) {
    LAShapeRectangle *rectangle = [[LAShapeRectangle alloc] initWithJSON:itemJSON frameRate:frameRate];
    return rectangle;
  } else if ([type isEqualToString:@"tm"]) {
    LAShapeTrimPath *trim = [[LAShapeTrimPath alloc] initWithJSON:itemJSON frameRate:frameRate];
    return trim;
  }
  return nil;
}

@end
