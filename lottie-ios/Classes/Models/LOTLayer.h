//
//  LOTLayer.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTPlatformCompat.h"
#import "LOTKeyframe.h"

@class LOTShapeGroup;
@class LOTMask;
@class LOTAsset;
@class LOTAssetGroup;

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
              withAssetGroup:(LOTAssetGroup *)assetGroup;

@property (nonatomic, readonly) NSString *layerName;
@property (nonatomic, readonly) NSString *referenceID;
@property (nonatomic, readonly) NSNumber *layerID;
@property (nonatomic, readonly) LOTLayerType layerType;
@property (nonatomic, readonly) NSNumber *parentID;
@property (nonatomic, readonly) NSNumber *startFrame;
@property (nonatomic, readonly) NSNumber *inFrame;
@property (nonatomic, readonly) NSNumber *outFrame;
@property (nonatomic, readonly) CGRect layerBounds;

@property (nonatomic, readonly) NSArray<LOTShapeGroup *> *shapes;
@property (nonatomic, readonly) NSArray<LOTMask *> *masks;

@property (nonatomic, readonly) NSNumber *layerWidth;
@property (nonatomic, readonly) NSNumber *layerHeight;
@property (nonatomic, readonly) UIColor *solidColor;
@property (nonatomic, readonly) LOTAsset *imageAsset;

@property (nonatomic, readonly) LOTKeyframeGroup *opacity;
@property (nonatomic, readonly) LOTKeyframeGroup *rotation;
@property (nonatomic, readonly) LOTKeyframeGroup *position;

@property (nonatomic, readonly) LOTKeyframeGroup *positionX;
@property (nonatomic, readonly) LOTKeyframeGroup *positionY;

@property (nonatomic, readonly) LOTKeyframeGroup *anchor;
@property (nonatomic, readonly) LOTKeyframeGroup *scale;

@property (nonatomic, readonly) LOTMatteType matteType;

@end
