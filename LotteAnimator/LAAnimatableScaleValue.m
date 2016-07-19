//
//  LAAnimatableScaleValue.m
//  LotteAnimator
//
//  Created by brandon_withrow on 7/11/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAAnimatableScaleValue.h"

@implementation LAAnimatableScaleValue

- (instancetype)initWithScaleValues:(NSDictionary *)scaleValues frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    _frameRate = frameRate;
  }
  return self;
}

@end
