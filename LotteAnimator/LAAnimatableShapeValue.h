//
//  LAAnimatableShapeValue.h
//  LotteAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAAnimatableShapeValue : NSObject

- (instancetype)initWithShapeValues:(NSDictionary *)shapeValues closed:(BOOL)closed;

@property (nonatomic, readonly) UIBezierPath *initialShape;

@property (nonatomic, readonly) NSArray<UIBezierPath *> *shapeKeyframes;
@property (nonatomic, readonly) NSArray<NSNumber *> *keyTimes;
@property (nonatomic, readonly) NSArray<CAMediaTimingFunction *> *timingFunctions;
@property (nonatomic, readonly) NSNumber *startFrame;
@property (nonatomic, readonly) NSNumber *durationFrames;

@end
