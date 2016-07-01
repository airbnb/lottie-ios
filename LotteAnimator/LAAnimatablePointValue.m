//
//  LAAnimatablePointValue.m
//  LotteAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAAnimatablePointValue.h"

@implementation LAAnimatablePointValue
@synthesize animation = _animation;
@synthesize keyPath = _keyPath;

- (instancetype)initWithPointValues:(NSDictionary *)pointValues
                       keyPath:(NSString *)keyPath
                      frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    _keyPath = [keyPath copy];
    NSArray *value = pointValues[@"k"];
    if ([value isKindOfClass:[NSArray class]] &&
        [[(NSArray *)value firstObject] isKindOfClass:[NSDictionary class]] &&
        [(NSDictionary *)[(NSArray *)value firstObject] objectForKey:@"t"]) {
      //Keframes
      [self _buildAnimationForKeyframes:value keyPath:keyPath frameRate:frameRate];
    } else {
      //Single Value, no animation
      _initialPoint = [self _pointFromValueArray:value];
    }
  }
  return self;
}

- (void)_buildAnimationForKeyframes:(NSArray<NSDictionary *> *)keyframes
                            keyPath:(NSString *)keyPath
                           frameRate:(NSNumber *)frameRate {
  NSMutableArray *keyTimes = [NSMutableArray array];
  NSMutableArray *timingFunctions = [NSMutableArray array];
  UIBezierPath *motionPath = [UIBezierPath new];
  
  NSNumber *startFrame = keyframes.firstObject[@"t"];
  NSNumber *endFrame = keyframes.lastObject[@"t"];
  
  NSAssert((startFrame && endFrame && startFrame.integerValue < endFrame.integerValue),
           @"Lotte: Keyframe animation has incorrect time values or invalid number of keyframes");
  
  // Calculate time bounds
  NSTimeInterval beginTime = startFrame.floatValue / frameRate.floatValue;
  NSNumber *durationFrames = @(endFrame.floatValue - startFrame.floatValue);
  NSTimeInterval durationTime = durationFrames.floatValue / frameRate.floatValue;
  
  BOOL addStartValue = YES;
  BOOL addTimePadding = NO;
  NSArray *outPoint = nil;
  
  for (NSDictionary *keyframe in keyframes) {
    // Get keyframe time value
    NSNumber *frame = keyframe[@"t"];
    // Calculate percentage value for keyframe.
    //CA Animations accept time values of 0-1 as a percentage of animation completed.
    NSNumber *timePercentage = @((frame.floatValue - startFrame.floatValue) / durationFrames.floatValue);
    
    if (outPoint) {
      //add out value
      [motionPath addLineToPoint:[self _pointFromValueArray:outPoint]];
      [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
      outPoint = nil;
    }
    
    NSArray *startPoint = keyframe[@"s"];
    if (addStartValue) {
      if (startPoint) {
        CGPoint sPoint = [self _pointFromValueArray:startPoint];
        if (keyframe == keyframes.firstObject) {
          [motionPath moveToPoint:sPoint];
          _initialPoint = sPoint;
        } else {
          [motionPath addLineToPoint:sPoint];
          [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        }
        addStartValue = NO;
      }
    }
    
    if (addTimePadding) {
      // add time padding
      NSNumber *holdPercentage = @(timePercentage.floatValue - 0.00001);
      [keyTimes addObject:[holdPercentage copy]];
      addTimePadding = NO;
    }
    
    // add end value if present for keyframe
    NSArray *endPoint = keyframe[@"e"];
    if (endPoint) {
      NSArray *controlPoint1 = keyframe[@"to"];
      NSArray *controlPoint2 = keyframe[@"ti"];
      
      if (controlPoint1 && controlPoint2) {
        // Quadratic Spatial Interpolation
        [motionPath addCurveToPoint:[self _pointFromValueArray:endPoint]
                      controlPoint1:[self _pointFromValueArray:controlPoint1]
                      controlPoint2:[self _pointFromValueArray:controlPoint2]];
      } else {
        // Linear Spatial Interpolation
        [motionPath addLineToPoint:[self _pointFromValueArray:endPoint]];
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
    
    // add time
    [keyTimes addObject:timePercentage];
    
    // Check if keyframe is a hold keyframe
    if ([keyframe[@"h"] boolValue]) {
      // set out value as start and flag next frame accordinly
      outPoint = startPoint;
      addStartValue = YES;
      addTimePadding = YES;
    }
  }
  
  _animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
  _animation.path = motionPath.CGPath;
  _animation.keyTimes = keyTimes;
  _animation.timingFunctions = timingFunctions;
  _animation.beginTime = beginTime;
  _animation.duration = durationTime;
  _animation.fillMode = kCAFillModeForwards;
}

- (CGPoint)_pointFromValueArray:(NSArray<NSNumber *> *)values {
  if (values.count >= 2) {
    return CGPointMake([values[0] floatValue], [values[1] floatValue]);
  }
  return CGPointZero;
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
