//
//  LAAnimatableColorValue.h
//  LotteAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAAnimatableValue.h"
#import <Foundation/Foundation.h>

@interface LAAnimatableColorValue : NSObject

- (instancetype)initWithColorValues:(NSDictionary *)colorValues;

- (void)prepareAnimationsForKeyPath:(NSString *)keyPath frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) UIColor *initialColor;
@property (nonatomic, readonly) NSString *keyPath;
@property (nonatomic, readonly) CAKeyframeAnimation *animation;

@end
