//
//  LAAnimatableShapeValue.h
//  LotteAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAAnimatableValue.h"
#import <Foundation/Foundation.h>

@interface LAAnimatableShapeValue : NSObject <LAAnimatableValue>

- (instancetype)initWithShapeValues:(id)shapeValues
                            keyPath:(NSString *)keyPath
                          frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) UIBezierPath *initialShape;

@end
