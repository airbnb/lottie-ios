//
//  LAMask.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LAAnimatableShapeValue;
@class LAAnimatableNumberValue;

typedef enum : NSUInteger {
  LAMaskModeAdd,
  LAMaskModeSubtract,
  LAMaskModeIntersect,
  LAMaskModeUnknown
} LAMaskMode;

@interface LAMask : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) BOOL closed;
@property (nonatomic, readonly) BOOL inverted;
@property (nonatomic, readonly) LAMaskMode maskMode;
@property (nonatomic, readonly) LAAnimatableShapeValue *maskPath;
@property (nonatomic, readonly) LAAnimatableNumberValue *opacity;

@end
