//
//  LOTShapeStroke.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTShapeStroke.h"
#import "LOTAnimatableNumberValue.h"
#import "LOTAnimatableColorValue.h"

@implementation LOTShapeStroke

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  NSDictionary *color = jsonDictionary[@"c"];
  if (color) {
    _color = [[LOTAnimatableColorValue alloc] initWithColorValues:color frameRate:frameRate];
  }
  
  NSDictionary *width = jsonDictionary[@"w"];
  if (width) {
    _width = [[LOTAnimatableNumberValue alloc] initWithNumberValues:width frameRate:frameRate];
  }
  
  NSDictionary *opacity = jsonDictionary[@"o"];
  if (opacity) {
    _opacity = [[LOTAnimatableNumberValue alloc] initWithNumberValues:opacity frameRate:frameRate];
    [_opacity remapValuesFromMin:@0 fromMax:@100 toMin:@0 toMax:@1];
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
      NSDictionary *value = dash[@"v"];
      LOTAnimatableNumberValue *numberValue = [[LOTAnimatableNumberValue alloc] initWithNumberValues:value frameRate:frameRate];
      [dashPattern addObject:[numberValue.initialValue copy]];
    }
    _lineDashPattern = dashPattern;
  }
}

@end
