//
//  CAAnimationGroup+LOTAnimatableGroup.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/19/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LOTAnimatableValue.h"

@interface CAAnimationGroup (LOTAnimatableGroup)

+ (nullable CAAnimationGroup *)LOT_animationGroupForAnimatablePropertiesWithKeyPaths:(nonnull NSDictionary<NSString *, id<LOTAnimatableValue>> *)properties;

@end
