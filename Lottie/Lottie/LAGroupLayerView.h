//
//  LAGroupLayerView.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/14/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LAAnimatableLayer.h"

@class LAShapeGroup;
@class LAShapeTransform;
@class LAShapeFill;
@class LAShapeStroke;
@class LAShapeTrimPath;

@interface LAGroupLayerView : LAAnimatableLayer

- (instancetype)initWithShapeGroup:(LAShapeGroup *)shapeGroup
                         transform:(LAShapeTransform *)previousTransform
                              fill:(LAShapeFill *)previousFill
                            stroke:(LAShapeStroke *)previousStroke
                          trimPath:(LAShapeTrimPath *)previousTrimPath
                      withDuration:(NSTimeInterval)duration;

@property (nonatomic, readonly) LAShapeGroup *shapeGroup;
@property (nonatomic, readonly) LAShapeTransform *shapeTransform;
@property (nonatomic, assign) BOOL debugModeOn;

@end
