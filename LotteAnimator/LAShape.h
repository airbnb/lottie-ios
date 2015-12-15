//
//  LAShape.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "MTLModel.h"

@interface LAShape : MTLModel <MTLJSONSerializing>

@property (nonatomic, getter=isClosed) BOOL closed;
@property (nonatomic, strong) LAPath *shapePath;

@property (nonatomic, strong) NSNumber *strokeWidth;
@property (nonatomic, strong) NSNumber *strokeOpacity;
@property (nonatomic, strong) NSArray *strokeColorElements;

@property (nonatomic, strong) NSNumber *fillOpacity;
@property (nonatomic, strong) NSArray *fillColorElements;

@property (nonatomic, copy) NSArray *positionArray;
@property (nonatomic, copy) NSArray *anchorPointArray;
@property (nonatomic, copy) NSArray *scaleArray;
@property (nonatomic, copy) NSNumber *rotation;
@property (nonatomic, copy) NSNumber *opacity;

@end
