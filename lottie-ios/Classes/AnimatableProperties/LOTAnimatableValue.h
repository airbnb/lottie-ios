//
//  LOTAnimatableValue.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/19/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol LOTAnimatableValue <NSObject>
// BW TODO Make this a class and remove all of the various animatable classes.
// The new LOTKeyframe and render system does away with all of the extra classes
- (CAKeyframeAnimation *)animationForKeyPath:(NSString *)keypath;
- (BOOL)hasAnimation;

@end
