//
//  LAAnimatableSizeValue.h
//  LotteAnimator
//
//  Created by brandon_withrow on 7/11/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAAnimatableRectValue : NSObject

- (instancetype)initWithRectValues:(NSDictionary *)rectValues;

@property (nonatomic, readonly) CGRect initialRect;
@property (nonatomic, readonly) NSArray *rectKeyframes;
@property (nonatomic, readonly) NSArray<NSNumber *> *keyTimes;
@property (nonatomic, readonly) NSArray<CAMediaTimingFunction *> *timingFunctions;
@property (nonatomic, readonly) NSNumber *startFrame;
@property (nonatomic, readonly) NSNumber *durationFrames;


@end
