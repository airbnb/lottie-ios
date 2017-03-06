//
//  LOTAnimationCache.h
//  Lottie
//
//  Created by Brandon Withrow on 1/9/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LOTComposition;

@interface LOTAnimationCache : NSObject

+ (instancetype)sharedCache;

- (void)addAnimation:(LOTComposition *)animation forKey:(NSString *)key;
- (LOTComposition *)animationForKey:(NSString *)key;

@end
