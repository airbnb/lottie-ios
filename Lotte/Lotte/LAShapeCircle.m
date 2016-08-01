//
//  LAShapeCircle.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeCircle.h"
#import "LAAnimatablePointValue.h"
#import "LAAnimatableScaleValue.h"

@implementation LAShapeCircle

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  NSDictionary *position = jsonDictionary[@"p"];
  if (position) {
    _position = [[LAAnimatablePointValue alloc] initWithPointValues:position frameRate:frameRate];
    _position.usePathAnimation = NO;
  }
  
  NSDictionary *scale = jsonDictionary[@"s"];
  if (scale) {
    _scale = [[LAAnimatableScaleValue alloc] initWithScaleValues:scale frameRate:frameRate];
  }
}

@end
