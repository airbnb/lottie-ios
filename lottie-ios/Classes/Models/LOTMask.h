//
//  LOTMask.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LOTAnimatableShapeValue;
@class LOTAnimatableNumberValue;

typedef enum : NSUInteger {
  LOTMaskModeAdd,
  LOTMaskModeSubtract,
  LOTMaskModeIntersect,
  LOTMaskModeUnknown
} LOTMaskMode;

@interface LOTMask : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) BOOL closed;
@property (nonatomic, readonly) BOOL inverted;
@property (nonatomic, readonly) LOTMaskMode maskMode;
@property (nonatomic, readonly) LOTAnimatableShapeValue *maskPath;
@property (nonatomic, readonly) LOTAnimatableNumberValue *opacity;

@end
