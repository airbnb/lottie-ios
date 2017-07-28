//
//  LOTShapeStar.m
//  Lottie
//
//  Created by brandon_withrow on 7/27/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTShapeStar.h"
#import "LOTAnimatableNumberValue.h"
#import "LOTAnimatablePointValue.h"

@implementation LOTShapeStar

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  NSDictionary *outerRadius = jsonDictionary[@"or"];
  if (outerRadius) {
    _outerRadius = [[LOTAnimatableNumberValue alloc] initWithNumberValues:outerRadius frameRate:frameRate];
  }
  
  NSDictionary *outerRoundness = jsonDictionary[@"os"];
  if (outerRoundness) {
    _outerRoundness = [[LOTAnimatableNumberValue alloc] initWithNumberValues:outerRoundness frameRate:frameRate];
  }
  
  NSDictionary *innerRadius = jsonDictionary[@"ir"];
  if (innerRadius) {
    _innerRadius = [[LOTAnimatableNumberValue alloc] initWithNumberValues:innerRadius frameRate:frameRate];
  }
  
  NSDictionary *innerRoundness = jsonDictionary[@"is"];
  if (innerRoundness) {
    _innerRoundness = [[LOTAnimatableNumberValue alloc] initWithNumberValues:innerRoundness frameRate:frameRate];
  }
  
  NSDictionary *position = jsonDictionary[@"p"];
  if (position) {
    _position = [[LOTAnimatablePointValue alloc] initWithPointValues:position frameRate:frameRate];
  }
  
  NSDictionary *numberOfPoints = jsonDictionary[@"pt"];
  if (numberOfPoints) {
    _numberOfPoints = [[LOTAnimatableNumberValue alloc] initWithNumberValues:numberOfPoints frameRate:frameRate];
  }
  
  NSDictionary *rotation = jsonDictionary[@"r"];
  if (rotation) {
    _rotation = [[LOTAnimatableNumberValue alloc] initWithNumberValues:rotation frameRate:frameRate];
  }
  
  NSNumber *type = jsonDictionary[@"sy"];
  _type = type.integerValue;
}

@end
