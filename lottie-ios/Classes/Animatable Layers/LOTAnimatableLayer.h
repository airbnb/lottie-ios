//
//  LOTAnimatableLayer.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/21/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface LOTAnimatableLayer : CALayer

- (instancetype)initWithDuration:(NSTimeInterval)duration NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSTimeInterval laAnimationDuration;

@end
