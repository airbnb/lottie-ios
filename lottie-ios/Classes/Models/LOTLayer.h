//
//  LOTLayer.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTPlatformCompat.h"

@class LOTShapeGroup;
@class LOTMask;
@class LOTAnimatableColorValue;
@class LOTAnimatablePointValue;
@class LOTAnimatableNumberValue;
@class LOTAnimatableScaleValue;
@class LOTComposition;

typedef enum : NSInteger {
  LOTLayerTypeNone,
  LOTLayerTypeSolid,
  LOTLayerTypeUnknown,
  LOTLayerTypeNull,
  LOTLayerTypeShape
} LOTLayerType;

typedef enum : NSInteger {
  LOTMatteTypeNone,
  LOTMatteTypeAdd,
  LOTMatteTypeInvert,
  LOTLayerTypeUknown
} LOTMatteType;

@interface LOTLayer : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary fromComposition:(LOTComposition *)composition;

@property (nonatomic, readonly) NSString *layerName;
@property (nonatomic, readonly) NSNumber *layerID;
@property (nonatomic, readonly) LOTLayerType layerType;
@property (nonatomic, readonly) NSNumber *parentID;
@property (nonatomic, readonly) NSNumber *inFrame;
@property (nonatomic, readonly) NSNumber *outFrame;
@property (nonatomic, readonly) CGRect compBounds;
@property (nonatomic, readonly) NSNumber *framerate;

@property (nonatomic, readonly) NSArray<LOTShapeGroup *> *shapes;
@property (nonatomic, readonly) NSArray<LOTMask *> *masks;

@property (nonatomic, readonly) NSNumber *solidWidth;
@property (nonatomic, readonly) NSNumber *solidHeight;
@property (nonatomic, readonly) UIColor *solidColor;

@property (nonatomic, readonly) LOTAnimatableNumberValue *opacity;
@property (nonatomic, readonly) LOTAnimatableNumberValue *rotation;
@property (nonatomic, readonly) LOTAnimatablePointValue *position;

@property (nonatomic, readonly) LOTAnimatableNumberValue *positionX;
@property (nonatomic, readonly) LOTAnimatableNumberValue *positionY;

@property (nonatomic, readonly) LOTAnimatablePointValue *anchor;
@property (nonatomic, readonly) LOTAnimatableScaleValue *scale;

@property (nonatomic, readonly) BOOL hasOutAnimation;
@property (nonatomic, readonly) BOOL hasInAnimation;
@property (nonatomic, readonly) BOOL hasInOutAnimation;
@property (nonatomic, readonly) NSArray *inOutKeyframes;
@property (nonatomic, readonly) NSArray *inOutKeyTimes;
@property (nonatomic, readonly) NSTimeInterval compDuration;

@property (nonatomic, readonly) LOTMatteType matteType;

@end
