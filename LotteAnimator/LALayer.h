//
//  LALayer.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LAShapeGroup;
@class LAMask;
@class LAAnimatableColorValue;
@class LAAnimatablePointValue;
@class LAAnimatableNumberValue;
@class LAAnimatableRectValue;
@class LAAnimatableScaleValue;

typedef enum : NSInteger {
  LALayerTypeNone,
  LALayerTypeSolid,
  LALayerTypeUnknown,
  LALayerTypeNull,
  LALayerTypeShape
} LALayerType;

@interface LALayer : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds;

@property (nonatomic, readonly) NSString *layerName;
@property (nonatomic, readonly) NSNumber *layerID;
@property (nonatomic, readonly) LALayerType layerType;
@property (nonatomic, readonly) NSNumber *parentID;
@property (nonatomic, strong) NSArray *childrenIDs;
@property (nonatomic, readonly) NSNumber *inFrame;
@property (nonatomic, readonly) NSNumber *outFrame;
@property (nonatomic, readonly) CGRect compBounds;

@property (nonatomic, readonly) NSArray<LAShapeGroup *> *shapes;
@property (nonatomic, readonly) NSArray<LAMask *> *masks;

@property (nonatomic, readonly) LAAnimatableRectValue *solidBounds;
@property (nonatomic, readonly) LAAnimatableColorValue *solidColor;

@property (nonatomic, readonly) LAAnimatableNumberValue *opacity;
@property (nonatomic, readonly) LAAnimatableNumberValue *rotation;
@property (nonatomic, readonly) LAAnimatablePointValue *position;

@property (nonatomic, readonly) LAAnimatablePointValue *anchor;
@property (nonatomic, readonly) LAAnimatableScaleValue *scale;

@end
