//
//  CAAnimationGroup+LAAnimatableGroup.m
//  LottieAnimator
//
//  Created by brandon_withrow on 7/19/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "CAAnimationGroup+LAAnimatableGroup.h"

@implementation CAAnimationGroup (LAAnimatableGroup)

+ (nullable CAAnimationGroup *)animationGroupForAnimatablePropertiesWithKeyPaths:(nonnull NSDictionary<NSString *, id<LAAnimatableValue>> *)properties {
  NSMutableArray *animations = [NSMutableArray array];
  NSTimeInterval animduration = 0;
  for (NSString *keyPath in properties.allKeys) {
    id <LAAnimatableValue>property = properties[keyPath];
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
