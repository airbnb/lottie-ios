//
//  LAEllipseShapeLayer.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/26/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAAnimatableLayer.h"
#import "LAModels.h"

@interface LAEllipseShapeLayer : LAAnimatableLayer

- (instancetype)initWithEllipseShape:(LAShapeCircle *)circleShape
                                fill:(LAShapeFill *)fill
                              stroke:(LAShapeStroke *)stroke
                                trim:(LAShapeTrimPath *)trim
                           transform:(LAShapeTransform *)transform
                        withDuration:(NSTimeInterval)duration;

@end
