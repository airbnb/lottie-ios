//
//  LALayer.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "MTLModel.h"
#import <UIKit/UIKit.h>

@class LALayerView;
@class LAShape;
@class LAMask;
@class LAAnimatableColorValue;
@class LAAnimatablePointValue;
@class LAAnimatableNumberValue;

typedef enum : NSUInteger {
  LALayerTypeNone,
  LALayerTypeSolid,
  LALayerTypeUnknown,
  LALayerTypeNull,
  LALayerTypeShape
} LALayerType;

@interface LALayer : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *layerName;
@property (nonatomic, copy) NSNumber *layerID;
@property (nonatomic, assign) LALayerType layerType;
@property (nonatomic, copy) NSNumber *parentID;
@property (nonatomic, copy) NSNumber *inPoint;
@property (nonatomic, copy) NSNumber *outPoint;

@property (nonatomic, copy) NSArray<LAShape *> *shapes;
@property (nonatomic, copy) NSArray<LAMask *> *masks;
@property (nonatomic, copy) LAAnimatableNumberValue *solidWidth;
@property (nonatomic, copy) LAAnimatableNumberValue *solidHeight;
@property (nonatomic, copy) LAAnimatableColorValue *solidColor;

@property (nonatomic, copy) LAAnimatableNumberValue *opacity;
@property (nonatomic, copy) LAAnimatableNumberValue *rotation;
@property (nonatomic, copy) LAAnimatablePointValue *position;
@property (nonatomic, copy) LAAnimatablePointValue *anchor;
//@property (nonatomic, copy) LAAnimatableProperty *scale; //TODO Make This

@end
