//
//  LOTRectShapeLayer.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/20/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LOTModels.h"
#import "LOTAnimatableLayer.h"

@interface LOTRectShapeLayer : LOTAnimatableLayer

- (instancetype)initWithRectShape:(LOTShapeRectangle *)rectShape
                             fill:(LOTShapeFill *)fill
                           stroke:(LOTShapeStroke *)stroke
                        transform:(LOTShapeTransform *)transform
                     withDuration:(NSTimeInterval)duration;

@end
