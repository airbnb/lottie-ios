//
//  LAShapeRectangle.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LAAnimatableBoundsValue.h"
#import "LAAnimatablePointValue.h"
#import "LAAnimatableNumberValue.h"

@interface LAShapeRectangle : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) LAAnimatablePointValue *position;
@property (nonatomic, readonly) LAAnimatableBoundsValue *bounds;
@property (nonatomic, readonly) LAAnimatableNumberValue *cornerRadius;

@end
