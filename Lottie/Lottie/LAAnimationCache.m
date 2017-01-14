//
//  LAAnimationCache.m
//  Lottie
//
//  Created by Brandon Withrow on 1/9/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "LAAnimationCache.h"

@implementation LAAnimationCache {
  NSMutableDictionary *animationsCache_;
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
  }
  return self;
}

- (void)addAnimation:(LAComposition *)animation forKey:(NSString *)key {
  [animationsCache_ setObject:animation forKey:key];
}

- (LAComposition *)animationForKey:(NSString *)key {
  return [animationsCache_ objectForKey:key];
}


@end
