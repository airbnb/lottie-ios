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
@class LOTAsset;
@class LOTAssetGroup;
@class LOTAnimatableColorValue;
@class LOTAnimatablePointValue;
@class LOTAnimatableNumberValue;
@class LOTAnimatableScaleValue;

typedef enum : NSInteger {
  LOTLayerTypePrecomp,
  LOTLayerTypeSolid,
  LOTLayerTypeImage,
  LOTLayerTypeNull,
  LOTLayerTypeShape,
  LOTLayerTypeUnknown
} LOTLayerType;

typedef enum : NSInteger {
  LOTMatteTypeNone,
  LOTMatteTypeAdd,
  LOTMatteTypeInvert,
  LOTMatteTypeUnknown
} LOTMatteType;

@interface LOTLayer : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary
              withCompBounds:(CGRect)compBounds
               withFramerate:(NSNumber *)framerate
              withAssetGroup:(LOTAssetGroup *)assetGroup;

@property (nonatomic, readonly) NSString *layerName;
@property (nonatomic, readonly) NSString *referenceID;
@property (nonatomic, readonly) NSNumber *layerID;
@property (nonatomic, readonly) LOTLayerType layerType;
@property (nonatomic, readonly) NSNumber *parentID;
@property (nonatomic, readonly) NSNumber *inFrame;
@property (nonatomic, readonly) NSNumber *outFrame;
@property (nonatomic, readonly) CGRect layerBounds;
@property (nonatomic, readonly) CGRect parentCompBounds;
@property (nonatomic, readonly) NSNumber *framerate;

@property (nonatomic, readonly) NSArray<LOTShapeGroup *> *shapes;
@property (nonatomic, readonly) NSArray<LOTMask *> *masks;

@property (nonatomic, readonly) NSNumber *layerWidth;
@property (nonatomic, readonly) NSNumber *layerHeight;
@property (nonatomic, readonly) UIColor *solidColor;
@property (nonatomic, readonly) LOTAsset *imageAsset;

@property (nonatomic, readonly) LOTAnimatableNumberValue *opacity;
@property (nonatomic, readonly) LOTAnimatableNumberValue *rotation;
@property (nonatomic, readonly) LOTAnimatablePointValue *position;

@property (nonatomic, readonly) LOTAnimatableNumberValue *positionX;
@property (nonatomic, readonly) LOTAnimatableNumberValue *positionY;

@property (nonatomic, readonly) LOTAnimatablePointValue *anchor;
@property (nonatomic, readonly) LOTAnimatableScaleValue *scale;

@property (nonatomic, readonly) BOOL hasInAnimation;
@property (nonatomic, readonly) NSArray *inOutKeyframes;
@property (nonatomic, readonly) NSArray *inOutKeyTimes;
@property (nonatomic, readonly) NSTimeInterval layerDuration;

@property (nonatomic, readonly) LOTMatteType matteType;

@end
