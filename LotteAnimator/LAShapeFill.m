//
//  LAShapeFill.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeFill.h"
#import "LAAnimatableNumberValue.h"
#import "LAAnimatableColorValue.h"

@implementation LAShapeFill

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
  
  NSDictionary *opacity = jsonDictionary[@"o"];
  if (opacity) {
    _opacity = [[LAAnimatableNumberValue alloc] initWithNumberValues:opacity];
  }
  
  NSNumber *fillEnabled = jsonDictionary[@"fillEnabled"];
  _fillEnabled = fillEnabled.boolValue;
}

@end
