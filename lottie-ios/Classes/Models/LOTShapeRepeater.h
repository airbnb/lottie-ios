//
//  LOTShapeRepeater.h
//  Lottie
//
//  Created by brandon_withrow on 7/28/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTAnimatableNumberValue.h"
#import "LOTAnimatablePointValue.h"
#import "LOTAnimatableScaleValue.h"

@interface LOTShapeRepeater : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary
                   frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) LOTAnimatableNumberValue *copies;
@property (nonatomic, readonly) LOTAnimatableNumberValue *offset;
@property (nonatomic, readonly) LOTAnimatablePointValue *anchorPoint;
@property (nonatomic, readonly) LOTAnimatableScaleValue *scale;
@property (nonatomic, readonly) LOTAnimatablePointValue *position;
@property (nonatomic, readonly) LOTAnimatableNumberValue *rotation;
@property (nonatomic, readonly) LOTAnimatableNumberValue *startOpacity;
@property (nonatomic, readonly) LOTAnimatableNumberValue *endOpacity;

@end
