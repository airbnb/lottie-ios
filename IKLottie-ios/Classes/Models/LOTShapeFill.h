//
//  LOTShapeFill.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LOTAnimatableColorValue;
@class LOTAnimatableNumberValue;

@interface LOTShapeFill : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) BOOL fillEnabled;
@property (nonatomic, readonly) LOTAnimatableColorValue *color;
@property (nonatomic, readonly) LOTAnimatableNumberValue *opacity;

@end
