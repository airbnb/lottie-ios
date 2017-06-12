//
//  LOTComposition.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LOTComposition : NSObject

+ (instancetype)compositionForAnimationNamed:(NSString *)animationName inBundle:(NSBundle *)bundle;

@end
