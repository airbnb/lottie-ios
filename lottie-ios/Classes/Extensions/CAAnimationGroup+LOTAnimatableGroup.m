//
//  CAAnimationGroup+LOTAnimatableGroup.m
//  LottieAnimator
//
//  Created by brandon_withrow on 7/19/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "CAAnimationGroup+LOTAnimatableGroup.h"

@implementation CAAnimationGroup (LOTAnimatableGroup)

+ (nullable CAAnimationGroup *)LOT_animationGroupForAnimatablePropertiesWithKeyPaths:(nonnull NSDictionary<NSString *, id<LOTAnimatableValue>> *)properties {
  NSMutableArray *animations = [NSMutableArray array];
  NSTimeInterval animduration = 0;
  for (NSString *keyPath in properties.allKeys) {
    id <LOTAnimatableValue>property = properties[keyPath];
    if ([property hasAnimation]) {
      CAKeyframeAnimation *animation = [property animationForKeyPath:keyPath];
      [animations addObject:animation];
      
      if (animation.duration + animation.beginTime > animduration) {
        animduration = animation.duration + animation.beginTime;
      }
    }
  }
  
  if (animations.count) {
    CAAnimationGroup *animation = [CAAnimationGroup new];
    animation.animations = animations;
    animation.duration = animduration;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
  }
  return nil;
}

@end
