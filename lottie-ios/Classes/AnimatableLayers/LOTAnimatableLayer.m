//
//  LOTAnimatableLayer.m
//  LottieAnimator
//
//  Created by brandon_withrow on 7/21/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTAnimatableLayer.h"

@implementation LOTAnimatableLayer

- (instancetype)initWithLayerDuration:(NSTimeInterval)duration {
  self = [super init];
  if (self) {
    _layerDuration = duration;
  }
  return self;
}

@end
