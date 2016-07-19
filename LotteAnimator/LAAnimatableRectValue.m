//
//  LAAnimatableSizeValue.m
//  LotteAnimator
//
//  Created by brandon_withrow on 7/11/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAAnimatableRectValue.h"

@implementation LAAnimatableRectValue

- (instancetype)initWithRectValues:(NSDictionary *)rectValues frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    _frameRate = frameRate;
  }
  return self;
}

@end
