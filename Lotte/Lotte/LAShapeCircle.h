//
//  LAShapeCircle.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LAAnimatablePointValue;
@class LAAnimatableScaleValue;

@interface LAShapeCircle : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) LAAnimatablePointValue *position;
@property (nonatomic, readonly) LAAnimatableScaleValue *scale;

@end
