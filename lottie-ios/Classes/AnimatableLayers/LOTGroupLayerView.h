//
//  LOTGroupLayerView.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/14/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LOTAnimatableLayer.h"

@class LOTShapeGroup;
@class LOTShapeTransform;
@class LOTShapeFill;
@class LOTShapeStroke;
@class LOTShapeTrimPath;

@interface LOTGroupLayerView : LOTAnimatableLayer

- (instancetype)initWithShapeGroup:(LOTShapeGroup *)shapeGroup
                         transform:(LOTShapeTransform *)previousTransform
                              fill:(LOTShapeFill *)previousFill
                            stroke:(LOTShapeStroke *)previousStroke
                          trimPath:(LOTShapeTrimPath *)previousTrimPath
                      withDuration:(NSTimeInterval)duration;

@property (nonatomic, readonly) LOTShapeGroup *shapeGroup;
@property (nonatomic, readonly) LOTShapeTransform *shapeTransform;
@property (nonatomic, assign) BOOL debugModeOn;

@end
