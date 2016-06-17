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

@interface LALayer : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *layerName;
@property (nonatomic, copy) NSNumber *layerID;
@property (nonatomic, copy) NSArray<LAShape *> *shapes;
@property (nonatomic, copy) NSArray<LAMask *> *masks;

@property (nonatomic, copy) NSNumber *width;
@property (nonatomic, copy) NSNumber *height;

@property (nonatomic, copy) NSArray *positionArray;
@property (nonatomic, copy) NSArray *anchorPointArray;
@property (nonatomic, copy) NSArray *scaleArray;
@property (nonatomic, copy) NSNumber *rotation;
@property (nonatomic, copy) NSNumber *opacity;
@property (nonatomic, copy) NSString *color;


// Readonly Helpers

@property (nonatomic, readonly) UIColor *bgColor;
@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, readonly) CGPoint anchorPoint;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) CGSize scale;
@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) CGRect frameRect;
@property (nonatomic, readonly) CGAffineTransform transform;

@end
