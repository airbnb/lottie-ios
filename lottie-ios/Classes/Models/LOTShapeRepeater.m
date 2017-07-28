//
//  LOTShapeRepeater.m
//  Lottie
//
//  Created by brandon_withrow on 7/28/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTShapeRepeater.h"
#import "CGGeometry+LOTAdditions.h"

@implementation LOTShapeRepeater

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary
                   frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  NSDictionary *copies = jsonDictionary[@"c"];
  if (copies) {
    _copies = [[LOTAnimatableNumberValue alloc] initWithNumberValues:copies frameRate:frameRate];
  }
  
  NSDictionary *offset = jsonDictionary[@"o"];
  if (offset) {
    _offset = [[LOTAnimatableNumberValue alloc] initWithNumberValues:offset frameRate:frameRate];
  }
  
  NSDictionary *transform = jsonDictionary[@"tr"];
  
  NSDictionary *rotation = transform[@"r"];
  if (rotation) {
    _rotation = [[LOTAnimatableNumberValue alloc] initWithNumberValues:rotation frameRate:frameRate];
    [_rotation.keyframeGroup remapKeyframesWithBlock:^CGFloat(CGFloat inValue) {
      return LOT_DegreesToRadians(inValue);
    }];
  }
  
  NSDictionary *startOpacity = transform[@"so"];
  if (startOpacity) {
    _startOpacity = [[LOTAnimatableNumberValue alloc] initWithNumberValues:startOpacity frameRate:frameRate];
    [_startOpacity.keyframeGroup remapKeyframesWithBlock:^CGFloat(CGFloat inValue) {
      return LOT_RemapValue(inValue, 0, 100, 0, 1);
    }];
  }
  
  NSDictionary *endOpacity = transform[@"eo"];
  if (endOpacity) {
    _endOpacity = [[LOTAnimatableNumberValue alloc] initWithNumberValues:endOpacity frameRate:frameRate];
    [_endOpacity.keyframeGroup remapKeyframesWithBlock:^CGFloat(CGFloat inValue) {
      return LOT_RemapValue(inValue, 0, 100, 0, 1);
    }];
  }
  
  NSDictionary *anchorPoint = transform[@"a"];
  if (anchorPoint) {
    _anchorPoint = [[LOTAnimatablePointValue alloc] initWithPointValues:anchorPoint frameRate:frameRate];
  }
  
  NSDictionary *position = transform[@"p"];
  if (position) {
    _position = [[LOTAnimatablePointValue alloc] initWithPointValues:position frameRate:frameRate];
  }
  
  NSDictionary *scale = transform[@"s"];
  if (scale) {
    _scale = [[LOTAnimatableScaleValue alloc] initWithScaleValues:scale frameRate:frameRate];
    [_scale.keyframeGroup remapKeyframesWithBlock:^CGFloat(CGFloat inValue) {
      return LOT_RemapValue(inValue, 0, 100, 0, 1);
    }];
  }


}

@end
