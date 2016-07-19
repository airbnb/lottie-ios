//
//  LAShapeTransform.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeTransform.h"
#import "LAAnimatableNumberValue.h"
#import "LAAnimatablePointValue.h"
#import "LAAnimatableScaleValue.h"

@implementation LAShapeTransform

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate compBounds:compBounds];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds {
  _compBounds = compBounds;
  
  NSDictionary *position = jsonDictionary[@"p"];
  if (position) {
    _position = [[LAAnimatablePointValue alloc] initWithPointValues:position frameRate:frameRate];
  }
  
  NSDictionary *anchor = jsonDictionary[@"a"];
  if (anchor) {
    _anchor = [[LAAnimatablePointValue alloc] initWithPointValues:anchor frameRate:frameRate];
    [_anchor remapPointsFromBounds:compBounds toBounds:CGRectMake(0, 0, 1, 1)];
  }
  
  NSDictionary *scale = jsonDictionary[@"s"];
  if (scale) {
    _scale = [[LAAnimatableScaleValue alloc] initWithScaleValues:scale frameRate:frameRate];
  }
  
  NSDictionary *rotation = jsonDictionary[@"r"];
  if (rotation) {
    _rotation = [[LAAnimatableNumberValue alloc] initWithNumberValues:rotation frameRate:frameRate];
  }
  
  NSDictionary *opacity = jsonDictionary[@"o"];
  if (opacity) {
    _opacity = [[LAAnimatableNumberValue alloc] initWithNumberValues:opacity frameRate:frameRate];
  }
}

@end
