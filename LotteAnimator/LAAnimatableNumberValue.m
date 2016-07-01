//
//  LAAnimatableNumberValue.m
//  LotteAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAAnimatableNumberValue.h"

@implementation LAAnimatableNumberValue

- (instancetype)initWithNumberValues:(NSDictionary *)numberValues
                             keyPath:(NSString *)keyPath
                           frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    _keyPath = [keyPath copy];
    id value = numberValues[@"k"];
    if ([value isKindOfClass:[NSArray class]] &&
        [[(NSArray *)value firstObject] isKindOfClass:[NSDictionary class]] &&
        [(NSDictionary *)[(NSArray *)value firstObject] objectForKey:@"t"]) {
      //Keframes
      [self _buildAnimationForKeyframes:value keyPath:keyPath frameRate:frameRate];
    } else {
      //Single Value, no animation
      _initialValue = [[self _numberValueFromObject:value] copy];
    }
  }
  return self;
}

- (void)_buildAnimationForKeyframes:(NSArray<NSDictionary *> *)keyframes
                            keyPath:(NSString *)keyPath
                          frameRate:(NSNumber *)frameRate {
  NSMutableArray *keyTimes = [NSMutableArray array];
  NSMutableArray *timingFunctions = [NSMutableArray array];
  NSMutableArray<NSNumber *> *numberValues = [NSMutableArray array];
  
  NSNumber *startFrame = keyframes.firstObject[@"t"];
  NSNumber *endFrame = keyframes.lastObject[@"t"];
  
  NSAssert((startFrame && endFrame && startFrame.integerValue < endFrame.integerValue),
           @"Lotte: Keyframe animation has incorrect time values or invalid number of keyframes");
  
  // Calculate time bounds in second-time.
  NSTimeInterval beginTime = startFrame.floatValue / frameRate.floatValue;
  NSNumber *durationFrames = @(endFrame.floatValue - startFrame.floatValue);
  NSTimeInterval durationTime = durationFrames.floatValue / frameRate.floatValue;
  
  BOOL addStartValue = YES;
  BOOL addTimePadding = NO;
  NSNumber *outValue = nil;
  
  for (NSDictionary *keyframe in keyframes) {
    // Get keyframe time value
    NSNumber *frame = keyframe[@"t"];
    // Calculate percentage value for keyframe.
    //CA Animations accept time values of 0-1 as a percentage of animation completed.
    NSNumber *timePercentage = @((frame.floatValue - startFrame.floatValue) / durationFrames.floatValue);
    
    if (outValue) {
      //add out value
      [numberValues addObject:[outValue copy]];
      [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
      outValue = nil;
    }
    
    NSNumber *startValue = [self _numberValueFromObject:keyframe[@"s"]];
    if (addStartValue) {
      // Add start value
      if (startValue) {
        if (keyframe == keyframes.firstObject) {
          _initialValue = startValue;
        }
        [numberValues addObject:[startValue copy]];
        if (timingFunctions.count) {
          [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        }
      }
      addStartValue = NO;
    }
    
    if (addTimePadding) {
      // add time padding
      NSNumber *holdPercentage = @(timePercentage.floatValue - 0.00001);
      [keyTimes addObject:[holdPercentage copy]];
      addTimePadding = NO;
    }
    
    // add end value if present for keyframe
    NSNumber *endValue = [self _numberValueFromObject:keyframe[@"e"]];
    if (endValue) {
      [numberValues addObject:[endValue copy]];
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
    
    // add time
    [keyTimes addObject:timePercentage];
    
    // Check if keyframe is a hold keyframe
    if ([keyframe[@"h"] boolValue]) {
      // set out value as start and flag next frame accordinly
      outValue = startValue;
      addStartValue = YES;
      addTimePadding = YES;
    }
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
  if ([valueObject isKindOfClass:[NSArray class]] &&
      [[valueObject firstObject] isKindOfClass:[NSNumber class]]) {
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
