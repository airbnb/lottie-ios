//
//  LOTShapeStar.h
//  Lottie
//
//  Created by brandon_withrow on 7/27/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LOTAnimatablePointValue;
@class LOTAnimatableNumberValue;

typedef enum : NSUInteger {
  LOTPolystarShapeNone,
  LOTPolystarShapeStar,
  LOTPolystarShapePolygon
} LOTPolystarShape;

@interface LOTShapeStar : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) LOTAnimatableNumberValue *outerRadius;
@property (nonatomic, readonly) LOTAnimatableNumberValue *outerRoundness;

@property (nonatomic, readonly) LOTAnimatableNumberValue *innerRadius;
@property (nonatomic, readonly) LOTAnimatableNumberValue *innerRoundness;

@property (nonatomic, readonly) LOTAnimatablePointValue *position;
@property (nonatomic, readonly) LOTAnimatableNumberValue *numberOfPoints;
@property (nonatomic, readonly) LOTAnimatableNumberValue *rotation;

@property (nonatomic, readonly) LOTPolystarShape type;

@end
