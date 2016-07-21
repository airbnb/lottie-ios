//
//  LARectShapeLayer.h
//  LotteAnimator
//
//  Created by brandon_withrow on 7/20/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LAAnimatableLayer.h"

@interface LARectShapeLayer : LAAnimatableLayer

- (instancetype)initWithRectShape:(LAShapeRectangle *)rectShape
                         fill:(LAShapeFill *)fill
                       stroke:(LAShapeStroke *)stroke
                    transform:(LAShapeTransform *)transform;

- (void)startAnimation;


@end
