//
//  LAShapeStroke.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LAAnimatableColorValue;
@class LAAnimatableNumberValue;

typedef enum : NSUInteger {
  LALineCapTypeButt,
  LALineCapTypeRound,
  LALineCapTypeUnknown
} LALineCapType;

typedef enum : NSUInteger {
  LALineJoinTypeMiter,
  LALineJoinTypeRound,
  LALineJoinTypeBevel
} LALineJoinType;

@interface LAShapeStroke : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) BOOL fillEnabled;
@property (nonatomic, readonly) LAAnimatableColorValue *color;
@property (nonatomic, readonly) LAAnimatableNumberValue *opacity;
@property (nonatomic, readonly) LAAnimatableNumberValue *width;
@property (nonatomic, readonly) LALineCapType capType;
@property (nonatomic, readonly) LALineJoinType joinType;

@property (nonatomic, readonly) NSArray *lineDashPattern;

@end
