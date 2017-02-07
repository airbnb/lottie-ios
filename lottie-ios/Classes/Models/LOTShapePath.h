//
//  LOTShapePath.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LOTAnimatableShapeValue;

@interface LOTShapePath : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) BOOL closed;
@property (nonatomic, readonly) NSNumber *index;
@property (nonatomic, readonly) LOTAnimatableShapeValue *shapePath;

@end
