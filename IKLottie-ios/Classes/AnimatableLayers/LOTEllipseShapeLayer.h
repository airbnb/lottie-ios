//
//  LOTEllipseShapeLayer.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/26/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTAnimatableLayer.h"
#import "LOTModels.h"

@interface LOTEllipseShapeLayer : LOTAnimatableLayer

- (instancetype)initWithEllipseShape:(LOTShapeCircle *)circleShape
                                fill:(LOTShapeFill *)fill
                              stroke:(LOTShapeStroke *)stroke
                                trim:(LOTShapeTrimPath *)trim
                           transform:(LOTShapeTransform *)transform
                        withLayerDuration:(NSTimeInterval)duration;

@end
