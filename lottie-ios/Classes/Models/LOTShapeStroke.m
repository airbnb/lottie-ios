//
//  LOTShapeStroke.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTShapeStroke.h"
#import "CGGeometry+LOTAdditions.h"

@implementation LOTShapeStroke

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {
  NSDictionary *color = jsonDictionary[@"c"];
  if (color) {
    _color = [[LOTKeyframeGroup alloc] initWithData:color];
  }
  
  NSDictionary *width = jsonDictionary[@"w"];
  if (width) {
    _width = [[LOTKeyframeGroup alloc] initWithData:width];
  }
  
  NSDictionary *opacity = jsonDictionary[@"o"];
  if (opacity) {
    _opacity = [[LOTKeyframeGroup alloc] initWithData:opacity];
    [_opacity remapKeyframesWithBlock:^CGFloat(CGFloat inValue) {
      return LOT_RemapValue(inValue, 0, 100, 0, 1);
    }];
  }
  
  _capType = [jsonDictionary[@"lc"] integerValue] - 1;
  _joinType = [jsonDictionary[@"lj"] integerValue] - 1;
  
  NSNumber *fillEnabled = jsonDictionary[@"fillEnabled"];
  _fillEnabled = fillEnabled.boolValue;
  
  NSArray *dashes = jsonDictionary[@"d"];
  if (dashes) {
    NSMutableArray *dashPattern = [NSMutableArray array];
    for (NSDictionary *dash in dashes) {
      if ([dash[@"n"] isEqualToString:@"o"]) {
        continue;
      }
      // TODO DASH PATTERNS
      NSDictionary *value = dash[@"v"];
//      LOTAnimatableNumberValue *numberValue = [[LOTKeyframeGroup alloc] initWithData:value];
//      [dashPattern addObject:[numberValue.initialValue copy]];
    }
    _lineDashPattern = dashPattern;
  }
}

@end
