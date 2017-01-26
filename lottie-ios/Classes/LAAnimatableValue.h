//
//  LAAnimatableValue.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/19/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LAAnimatableValue <NSObject>

- (nullable CAKeyframeAnimation *)animationForKeyPath:(nonnull NSString *)keypath;
- (BOOL)hasAnimation;

@end
