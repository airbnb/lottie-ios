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
@class LAAnimatableProperty;

@interface LALayer : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *layerName;
@property (nonatomic, copy) NSNumber *layerID;
@property (nonatomic, copy) NSNumber *layerType;
@property (nonatomic, copy) NSNumber *parentID;
@property (nonatomic, copy) NSNumber *inPoint;
@property (nonatomic, copy) NSNumber *outPoint;

@property (nonatomic, copy) NSArray<LAShape *> *shapes;
@property (nonatomic, copy) NSArray<LAMask *> *masks;
@property (nonatomic, copy) LAAnimatableProperty *solidWidth;
@property (nonatomic, copy) LAAnimatableProperty *solidHeight;
@property (nonatomic, copy) LAAnimatableProperty *solidColor;

@property (nonatomic, copy) LAAnimatableProperty *opacity;
@property (nonatomic, copy) LAAnimatableProperty *rotation;
@property (nonatomic, copy) LAAnimatableProperty *position;
@property (nonatomic, copy) LAAnimatableProperty *anchor;
@property (nonatomic, copy) LAAnimatableProperty *scale;

@end
