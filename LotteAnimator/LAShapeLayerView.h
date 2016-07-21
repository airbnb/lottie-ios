//
//  LAShapeLayerView.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 7/13/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LAAnimatableLayer.h"

@interface LAShapeLayerView : LAAnimatableLayer

- (instancetype)initWithShape:(LAShapePath *)shape
                         fill:(LAShapeFill *)fill
                       stroke:(LAShapeStroke *)stroke
                    transform:(LAShapeTransform *)transform;

- (void)startAnimation;

@end
