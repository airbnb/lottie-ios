//
//  LAShapeLayerView.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 7/13/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LAAnimatableLayer.h"
#import "LAModels.h"

@interface LAShapeLayerView : LAAnimatableLayer

- (instancetype)initWithShape:(LAShapePath *)shape
                         fill:(LAShapeFill *)fill
                       stroke:(LAShapeStroke *)stroke
                         trim:(LAShapeTrimPath *)trim
                    transform:(LAShapeTransform *)transform
                 withDuration:(NSTimeInterval)duration;

@end
