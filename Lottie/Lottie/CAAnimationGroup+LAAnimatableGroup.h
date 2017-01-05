//
//  CAAnimationGroup+LAAnimatableGroup.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/19/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LAAnimatableValue.h"

@interface CAAnimationGroup (LAAnimatableGroup)

+ (nullable CAAnimationGroup *)animationGroupForAnimatablePropertiesWithKeyPaths:(nonnull NSDictionary<NSString *, id<LAAnimatableValue>> *)properties;

@end
