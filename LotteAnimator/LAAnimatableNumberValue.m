//
//  LAAnimatableNumberValue.m
//  LotteAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAAnimatableNumberValue.h"

@implementation LAAnimatableNumberValue
@synthesize animation = _animation;
@synthesize keyPath = _keyPath;

- (instancetype)initWithNumberValues:(id)numberValues
                             keyPath:(NSString *)keyPath
                           frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    _keyPath = [keyPath copy];
    id value = numberValues[@"k"];
    if ([value isKindOfClass:[NSNumber class]]) {
      //Single Value, no animation
      _initialValue = value;
    } else if ([value isKindOfClass:[NSArray class]]) {
      //Keframes
      [self _buildAnimationForKeyframes:value keyPath:keyPath frameRate:frameRate];
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
  
  // Calculate time bounds in second-time.
  NSTimeInterval beginTime = startFrame.floatValue / frameRate.floatValue;
  NSNumber *durationFrames = @(endFrame.floatValue - startFrame.floatValue);
  NSTimeInterval durationTime = durationFrames.floatValue / frameRate.floatValue;
  // TODO Figure out timing function
  
  BOOL addStartValue = YES;
  BOOL addTimePadding = NO;
  id outValue = nil;
  for (NSDictionary *keyframe in keyframes) {
    
    if (outValue) {
      //add out value
      outValue = nil;
    }
    
    if (addStartValue) {
      // Add start value
      addStartValue = NO;
    }
    
    if (addTimePadding) {
      // add time padding
      addTimePadding = NO;
    }
    
    
    
    // add end value if present
    
    // add time
    
    
    
    //if self.hold
    //set out value as start value
    addStartValue = YES;
    addTimePadding = YES;
    
  }
  
  
  NSNumber *previousOutValue = nil;
  BOOL previousFrameWasHold = NO;
  
  for (NSDictionary *keyframe in keyframes) {
    // Get keyframe time value
    NSNumber *frame = keyframe[@"t"];
    // Calculate percentage value for keyframe.
    //CA Animations accept time values of 0-1 as a percentage of animation completed.
    NSNumber *timePercentage = @((frame.floatValue - startFrame.floatValue) / durationFrames.floatValue);
    
    if (previousFrameWasHold) {
      // For Hold frames we need to add a padding keyframe to hold the value
      // The time value for the padding needs to be right up against the next keyframe
      NSNumber *holdPercentage = @(timePercentage.floatValue - 0.00001);
      [keyTimes addObject:[holdPercentage copy]];
      [numberValues addObject:[previousOutValue copy]];
      [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
      previousFrameWasHold = NO;
    }
    
    // Add time value for keyframe
    [keyTimes addObject:[timePercentage copy]];
    
    // Get the start and end value.
    NSNumber *startValue = [self _numberValueFromObject:keyframe[@"s"]];
    NSNumber *endValue = [self _numberValueFromObject:keyframe[@"e"]];
    // Hold keyframes and final keyframes do not have an end value.
    previousOutValue = endValue ?: startValue;
    
    // End keyframes often do not have an end value.
    [numberValues addObject:[(startValue ?: previousOutValue) copy]];
    
    previousFrameWasHold = [keyframe[@"h"] boolValue];
    
    if (keyframes.firstObject == keyframe) {
      _initialValue = [startValue copy];
    }
    
    if (keyframe == keyframes.lastObject) {
      // No Timing Function for final keyframe.
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
