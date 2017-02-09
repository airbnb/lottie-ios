//
//  LOTAnimatableLayer.m
//  LottieAnimator
//
//  Created by brandon_withrow on 7/21/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTAnimatableLayer.h"

@implementation LOTAnimatableLayer

- (instancetype)initWithDuration:(NSTimeInterval)duration {
  self = [super init];
  if (self) {
    _laAnimationDuration = duration;
  }
  return self;
}

@end
