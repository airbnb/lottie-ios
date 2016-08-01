//
//  LAGroupLayerView.h
//  LotteAnimator
//
//  Created by brandon_withrow on 7/14/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LAAnimatableLayer.h"

@class LAShapeGroup;
@class LAShapeTransform;

@interface LAGroupLayerView : LAAnimatableLayer

- (instancetype)initWithShapeGroup:(LAShapeGroup *)shapeGroup
                         transform:(LAShapeTransform *)transform
                      withDuration:(NSTimeInterval)duration;

@property (nonatomic, readonly) LAShapeGroup *shapeGroup;
@property (nonatomic, readonly) LAShapeTransform *shapeTransform;
@property (nonatomic, assign) BOOL debugModeOn;

@end
