//
//  LOTShape.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTShapeGroup.h"
#import "LOTShapeFill.h"
#import "LOTShapePath.h"
#import "LOTShapeCircle.h"
#import "LOTShapeStroke.h"
#import "LOTShapeTransform.h"
#import "LOTShapeRectangle.h"
#import "LOTShapeTrimPath.h"

@implementation LOTShapeGroup

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
    id newItem = [LOTShapeGroup shapeItemWithJSON:itemJSON frameRate:frameRate compBounds:compBounds];
    if (newItem) {
      [items addObject:newItem];
    }
  }
  _items = items;
}

+ (id)shapeItemWithJSON:(NSDictionary *)itemJSON frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds {
  NSString *type = itemJSON[@"ty"];
  if ([type isEqualToString:@"gr"]) {
    LOTShapeGroup *group = [[LOTShapeGroup alloc] initWithJSON:itemJSON frameRate:frameRate compBounds:compBounds];
    return group;
  } else if ([type isEqualToString:@"st"]) {
    LOTShapeStroke *stroke = [[LOTShapeStroke alloc] initWithJSON:itemJSON frameRate:frameRate];
    return stroke;
  } else if ([type isEqualToString:@"fl"]) {
    LOTShapeFill *fill = [[LOTShapeFill alloc] initWithJSON:itemJSON frameRate:frameRate];
    return fill;
  } else if ([type isEqualToString:@"tr"]) {
    LOTShapeTransform *transform = [[LOTShapeTransform alloc] initWithJSON:itemJSON frameRate:frameRate compBounds:compBounds];
    return transform;
  } else if ([type isEqualToString:@"sh"]) {
    LOTShapePath *path = [[LOTShapePath alloc] initWithJSON:itemJSON frameRate:frameRate];
    return path;
  } else if ([type isEqualToString:@"el"]) {
    LOTShapeCircle *circle = [[LOTShapeCircle alloc] initWithJSON:itemJSON frameRate:frameRate];
    return circle;
  } else if ([type isEqualToString:@"rc"]) {
    LOTShapeRectangle *rectangle = [[LOTShapeRectangle alloc] initWithJSON:itemJSON frameRate:frameRate];
    return rectangle;
  } else if ([type isEqualToString:@"tm"]) {
    LOTShapeTrimPath *trim = [[LOTShapeTrimPath alloc] initWithJSON:itemJSON frameRate:frameRate];
    return trim;
  } else {
    NSString *name = itemJSON[@"nm"];
    if ([type isEqualToString:@"gs"] /* gradient stroke */ || [type isEqualToString:@"gf"] /* gradient fill */) {
      NSLog(@"%s: Warning: gradients are not supported", __PRETTY_FUNCTION__);
    } else if ([type isEqualToString:@"sr"]) {
      NSLog(@"%s: Warning: star is not supported. Convert to vector path? name: %@", __PRETTY_FUNCTION__, name);
    } else if ([type isEqualToString:@"mm"]) {
      NSLog(@"%s: Warning: merge shape is not supported. name: %@", __PRETTY_FUNCTION__, name);
    } else {
      NSLog(@"%s: Unsupported shape: %@ name: %@", __PRETTY_FUNCTION__, type, name);
    }
  }
  return nil;
}

- (NSString*)description {
    NSMutableString *text = [[super description] mutableCopy];
    [text appendFormat:@" items: %@", self.items];
    return text;
}

@end
