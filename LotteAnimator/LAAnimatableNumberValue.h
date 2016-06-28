//
//  LAAnimatableNumberValue.h
//  LotteAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAAnimatableValue.h"
#import <Foundation/Foundation.h>

@interface LAAnimatableNumberValue : NSObject <LAAnimatableValue>

- (instancetype)initWithNumberValues:(NSDictionary *)numberValues
                            keyPath:(NSString *)keyPath
                          frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) NSNumber *initialValue;

@end
