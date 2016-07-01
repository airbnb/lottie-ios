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

- (instancetype)initWithShapeValues:(NSDictionary *)shapeValues
                            keyPath:(NSString *)keyPath
                          frameRate:(NSNumber *)frameRate
                         closedPath:(BOOL)closedPath;

@property (nonatomic, readonly) UIBezierPath *initialShape;
@property (nonatomic, readonly) NSString *keyPath;
@property (nonatomic, readonly) CAKeyframeAnimation *animation;

@end
