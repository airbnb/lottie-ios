//
//  LOTShapeStroke.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LOTAnimatableColorValue;
@class LOTAnimatableNumberValue;

typedef enum : NSUInteger {
  LOTLineCapTypeButt,
  LOTLineCapTypeRound,
  LOTLineCapTypeUnknown
} LOTLineCapType;

typedef enum : NSUInteger {
  LOTLineJoinTypeMiter,
  LOTLineJoinTypeRound,
  LOTLineJoinTypeBevel
} LOTLineJoinType;

@interface LOTShapeStroke : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate;

@property (nonatomic, readonly) BOOL fillEnabled;
@property (nonatomic, readonly) LOTAnimatableColorValue *color;
@property (nonatomic, readonly) LOTAnimatableNumberValue *opacity;
@property (nonatomic, readonly) LOTAnimatableNumberValue *width;
@property (nonatomic, readonly) LOTLineCapType capType;
@property (nonatomic, readonly) LOTLineJoinType joinType;

@property (nonatomic, readonly) NSArray *lineDashPattern;

@end
