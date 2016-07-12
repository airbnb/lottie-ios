//
//  LAAnimatableNumberValue.h
//  LotteAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAAnimatableNumberValue : NSObject

- (instancetype)initWithNumberValues:(NSDictionary *)numberValues;

@property (nonatomic, readonly) NSNumber *initialValue;
@property (nonatomic, readonly) NSArray<NSNumber *> *valueKeyframes;
@property (nonatomic, readonly) NSArray<NSNumber *> *keyTimes;
@property (nonatomic, readonly) NSArray<CAMediaTimingFunction *> *timingFunctions;
@property (nonatomic, readonly) NSNumber *startFrame;
@property (nonatomic, readonly) NSNumber *durationFrames;

@end
