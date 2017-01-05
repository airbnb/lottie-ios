//
//  LAShapeRectangle.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LAAnimatableBoundsValue;
@class LAAnimatablePointValue;
@class LAAnimatableNumberValue;

@interface LAShapeRectangle : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) LAAnimatablePointValue *position;
@property (nonatomic, readonly) LAAnimatablePointValue *size;
@property (nonatomic, readonly) LAAnimatableNumberValue *cornerRadius;

@end
