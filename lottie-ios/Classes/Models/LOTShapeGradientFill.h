//
//  LOTShapeGradientFill.h
//  Lottie
//
//  Created by brandon_withrow on 7/26/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTAnimatablePointValue.h"
#import "LOTAnimatableNumberValue.h"

@interface LOTShapeGradientFill : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) NSNumber *numberOfColors;
@property (nonatomic, readonly) LOTAnimatablePointValue *startPoint;
@property (nonatomic, readonly) LOTAnimatablePointValue *endPoint;
@property (nonatomic, readonly) LOTAnimatableNumberValue *gradient;
@property (nonatomic, readonly) LOTAnimatableNumberValue *opacity;
@property (nonatomic, readonly) BOOL evenOddFillRule;

@end
