//
//  LAAnimatableShapeValue.h
//  LottieAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LAAnimatableValue.h"

@interface LAAnimatableShapeValue : NSObject <LAAnimatableValue>

- (instancetype)initWithShapeValues:(NSDictionary *)shapeValues frameRate:(NSNumber *)frameRate closed:(BOOL)closed;

@property (nonatomic, readonly) UIBezierPath *initialShape;

@end
