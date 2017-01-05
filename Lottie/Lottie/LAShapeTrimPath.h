//
//  LAShapeTrimPath.h
//  LottieAnimator
//
//  Created by brandon_withrow on 7/26/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LAAnimatableNumberValue;

@interface LAShapeTrimPath : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) LAAnimatableNumberValue *start;
@property (nonatomic, readonly) LAAnimatableNumberValue *end;
@property (nonatomic, readonly) LAAnimatableNumberValue *offset;
@end
