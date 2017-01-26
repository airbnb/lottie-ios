//
//  LAAnimationCache.h
//  Lottie
//
//  Created by Brandon Withrow on 1/9/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LAComposition;

@interface LAAnimationCache : NSObject

+ (instancetype)sharedCache;

- (void)addAnimation:(LAComposition *)animation forKey:(NSString *)key;
- (LAComposition *)animationForKey:(NSString *)key;

@end
