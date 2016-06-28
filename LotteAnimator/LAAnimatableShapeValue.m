//
//  LAAnimatableShapeValue.m
//  LotteAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAAnimatableShapeValue.h"

@implementation LAAnimatableShapeValue
@synthesize animation = _animation;
@synthesize keyPath = _keyPath;

- (instancetype)initWithShapeValues:(id)shapeValues
                             keyPath:(NSString *)keyPath
                           frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    _keyPath = [keyPath copy];
    if ([numberValues isKindOfClass:[NSNumber class]]) {
      //Single Value, no animation
      _initialValue = numberValues;
    } else if ([numberValues isKindOfClass:[NSArray class]]) {
      //Keframes
      [self _buildAnimationForKeyframes:numberValues keyPath:keyPath frameRate:frameRate];
    }
  }
  return self;
}

- (void)_buildAnimationForKeyframes:(NSArray<NSDictionary *> *)keyframes
                            keyPath:(NSString *)keyPath
                          frameRate:(NSNumber *)frameRate {
  NSMutableArray *keyTimes = [NSMutableArray array];
  NSMutableArray *timingFunctions = [NSMutableArray array];
  NSMutableArray *numberValues = [NSMutableArray array];
  
  NSNumber *startFrame = keyframes.firstObject[@"t"];
  NSNumber *endFrame = keyframes.lastObject[@"t"];
  
  NSAssert((startFrame && endFrame && startFrame.integerValue < endFrame.integerValue),
           @"Lotte: Keyframe animation has incorrect time values or invalid number of keyframes");
  
  // Calculate time bounds
  NSTimeInterval beginTime = startFrame.floatValue / frameRate.floatValue;
  NSNumber *durationFrames = @(endFrame.floatValue - startFrame.floatValue);
  NSTimeInterval durationTime = durationFrames.floatValue / frameRate.floatValue;
  
  BOOL previousFrameWasHold = NO;
  for (NSDictionary *keyframe in keyframes) {
    /*
     * Add keyframeTime
     */
    NSNumber *frame = keyframe[@"t"];
    NSNumber *timePercentage = @((frame.floatValue - startFrame.floatValue) / durationFrames.floatValue);
    
    if (previousFrameWasHold) {
      NSNumber *holdPercentage = @(timePercentage.floatValue - 0.00001);
      [keyTimes addObject:holdPercentage];
      previousFrameWasHold = NO;
    }
    
    [keyTimes addObject:timePercentage];
    
    if (keyframe == keyframes.lastObject) {
      // Last object is always just a time value.
      continue;
    }
    
    /*
     * Timing Function for time interpolations between keyframes
     * Should be n-1 where n is the number of keyframes
     */
    CAMediaTimingFunction *timingFunction;
    NSDictionary *timingControlPoint1 = keyframe[@"o"];
    NSDictionary *timingControlPoint2 = keyframe[@"i"];
    
    if (timingControlPoint1 && timingControlPoint2) {
      // Easing function
      CGPoint cp1 = [self _pointFromValueDict:timingControlPoint1];
      CGPoint cp2 = [self _pointFromValueDict:timingControlPoint2];
      timingFunction = [CAMediaTimingFunction functionWithControlPoints:cp1.x :cp1.y :cp2.x :cp2.y];
    } else {
      // No easing function specified, fallback to linear
      timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
    [timingFunctions addObject:timingFunction];
    
    /*
     * Number Value
     */
    NSNumber *startValue = [self _numberValueFromObject:keyframe[@"s"]];
    NSNumber *endValue = [self _numberValueFromObject:keyframe[@"e"]];
    
    if (keyframes.firstObject == keyframe) {
      _initialValue = startValue;
      [numberValues addObject:startValue];
    }
    
    if ([keyframe[@"h"] boolValue] == YES) {
      endValue = startValue;
      previousFrameWasHold = YES;
      [numberValues addObject:endValue];
      // Pad extra keyframe for hold
    }
    
    [numberValues addObject:endValue];
  }
  
  _animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
  _animation.values = numberValues;
  _animation.keyTimes = keyTimes;
  _animation.timingFunctions = timingFunctions;
  _animation.beginTime = beginTime;
  _animation.duration = durationTime;
  _animation.fillMode = kCAFillModeForwards;
}

- (NSNumber *)_numberValueFromObject:(id)valueObject {
  if ([valueObject isKindOfClass:[NSNumber class]]) {
    return valueObject;
  }
  if ([valueObject isKindOfClass:[NSArray class]]) {
    return [(NSArray *)valueObject firstObject];
  }
  return nil;
}

- (CGPoint)_pointFromValueDict:(NSDictionary *)values {
  NSNumber *xValue = @0, *yValue = @0;
  if ([values[@"x"] isKindOfClass:[NSNumber class]]) {
    xValue = values[@"x"];
  } else if ([values[@"x"] isKindOfClass:[NSArray class]]) {
    xValue = values[@"x"][0];
  }
  
  if ([values[@"y"] isKindOfClass:[NSNumber class]]) {
    yValue = values[@"y"];
  } else if ([values[@"y"] isKindOfClass:[NSArray class]]) {
    yValue = values[@"y"][0];
  }
  
  return CGPointMake([xValue floatValue], [yValue floatValue]);
}


@end
