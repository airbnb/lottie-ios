//
//  LAGroupLayerView.h
//  LotteAnimator
//
//  Created by brandon_withrow on 7/14/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
@class LAShapeGroup;
@class LAShapeTransform;

@interface LAGroupLayerView : CALayer

- (instancetype)initWithShapeGroup:(LAShapeGroup *)shapeGroup
                         transform:(LAShapeTransform *)transform;

@property (nonatomic, assign) BOOL debugModeOn;

@end
