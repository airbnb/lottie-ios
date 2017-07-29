//
//  LOTMask.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTKeyframe.h"

typedef enum : NSUInteger {
  LOTMaskModeAdd,
  LOTMaskModeSubtract,
  LOTMaskModeIntersect,
  LOTMaskModeUnknown
} LOTMaskMode;

@interface LOTMask : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary;

@property (nonatomic, readonly) BOOL closed;
@property (nonatomic, readonly) BOOL inverted;
@property (nonatomic, readonly) LOTMaskMode maskMode;
@property (nonatomic, readonly) LOTKeyframeGroup *maskPath;
@property (nonatomic, readonly) LOTKeyframeGroup *opacity;
@property (nonatomic, readonly) LOTKeyframeGroup *expansion;
@end
