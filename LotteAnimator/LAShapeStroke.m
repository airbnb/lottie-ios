//
//  LAShapeStroke.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeStroke.h"
#import "LAAnimatableNumberValue.h"
#import "LAAnimatableColorValue.h"

@implementation LAShapeStroke

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
    _color = [[LAAnimatableColorValue alloc] initWithColorValues:color];
  }
  
  NSDictionary *width = jsonDictionary[@"w"];
  if (width) {
    _width = [[LAAnimatableNumberValue alloc] initWithNumberValues:width];
  }
  
  NSDictionary *opacity = jsonDictionary[@"o"];
  if (opacity) {
    _opacity = [[LAAnimatableNumberValue alloc] initWithNumberValues:opacity];
    [_opacity remapValuesFromMin:@0 fromMax:@100 toMin:@0 toMax:@1];
  }
  
  NSNumber *fillEnabled = jsonDictionary[@"fillEnabled"];
  _fillEnabled = fillEnabled.boolValue;
}

@end
