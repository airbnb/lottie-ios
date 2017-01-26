//
//  LAAnimationCache.m
//  Lottie
//
//  Created by Brandon Withrow on 1/9/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "LAAnimationCache.h"

const NSInteger kLACacheSize = 50;

@implementation LAAnimationCache {
  NSMutableDictionary *animationsCache_;
  NSMutableArray *lruOrderArray_;
}

+ (instancetype)sharedCache {
  static LAAnimationCache *sharedCache = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedCache = [[self alloc] init];
  });
  return sharedCache;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    animationsCache_ = [[NSMutableDictionary alloc] init];
    lruOrderArray_ = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)addAnimation:(LAComposition *)animation forKey:(NSString *)key {
  if (lruOrderArray_.count >= kLACacheSize) {
    NSString *oldKey = lruOrderArray_[0];
    [animationsCache_ removeObjectForKey:oldKey];
    [lruOrderArray_ removeObject:oldKey];
  }
  [lruOrderArray_ removeObject:key];
  [lruOrderArray_ addObject:key];
  [animationsCache_ setObject:animation forKey:key];
}

- (LAComposition *)animationForKey:(NSString *)key {
  LAComposition *animation = [animationsCache_ objectForKey:key];
  [lruOrderArray_ removeObject:key];
  [lruOrderArray_ addObject:key];
  return animation;
}


@end
