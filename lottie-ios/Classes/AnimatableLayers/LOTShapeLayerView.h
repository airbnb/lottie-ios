//
//  LOTShapeLayerView.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 7/13/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTAnimatableLayer.h"
#import "LOTModels.h"

@interface LOTShapeLayerView : LOTAnimatableLayer

- (instancetype)initWithShape:(LOTShapePath *)shape
                         fill:(LOTShapeFill *)fill
                       stroke:(LOTShapeStroke *)stroke
                         trim:(LOTShapeTrimPath *)trim
                    transform:(LOTShapeTransform *)transform
                 withDuration:(NSTimeInterval)duration;

@end
