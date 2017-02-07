//
//  LOTShapeTrimPath.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/26/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LOTAnimatableNumberValue;

@interface LOTShapeTrimPath : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) LOTAnimatableNumberValue *start;
@property (nonatomic, readonly) LOTAnimatableNumberValue *end;
@property (nonatomic, readonly) LOTAnimatableNumberValue *offset;
@end
