//
//  LAAnimatableColorValue.m
//  LotteAnimator
//
//  Created by brandon_withrow on 6/23/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAAnimatableColorValue.h"

@implementation LAAnimatableColorValue
@synthesize animation = _animation;
@synthesize keyPath = _keyPath;

- (instancetype)initWithColorValues:(NSDictionary *)colorValues
                            keyPath:(NSString *)keyPath
                          frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    _keyPath = [keyPath copy];
    NSArray *value = colorValues[@"k"];
    if ([value isKindOfClass:[NSArray class]] &&
        [[(NSArray *)value firstObject] isKindOfClass:[NSDictionary class]] &&
        [(NSDictionary *)[(NSArray *)value firstObject] objectForKey:@"t"]) {
      //Keframes
      [self _buildAnimationForKeyframes:value keyPath:keyPath frameRate:frameRate];
    } else {
      //Single Value, no animation
      _initialColor = [[self _colorValueFromArray:value] copy];
    }
  }
  return self;
}

- (void)_buildAnimationForKeyframes:(NSArray<NSDictionary *> *)keyframes
                            keyPath:(NSString *)keyPath
                          frameRate:(NSNumber *)frameRate {
  NSMutableArray *keyTimes = [NSMutableArray array];
  NSMutableArray *timingFunctions = [NSMutableArray array];
  NSMutableArray<UIColor *> *colorValues = [NSMutableArray array];
  
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
  UIColor *outColor = nil;
  
  for (NSDictionary *keyframe in keyframes) {
    // Get keyframe time value
    NSNumber *frame = keyframe[@"t"];
    // Calculate percentage value for keyframe.
    //CA Animations accept time values of 0-1 as a percentage of animation completed.
    NSNumber *timePercentage = @((frame.floatValue - startFrame.floatValue) / durationFrames.floatValue);
    
    if (outColor) {
      //add out value
      [colorValues addObject:(id)[[outColor copy] CGColor]];
      [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
      outColor = nil;
    }
    
    UIColor *startColor = [self _colorValueFromArray:keyframe[@"s"]];
    if (addStartValue) {
      // Add start value
      if (startColor) {
        if (keyframe == keyframes.firstObject) {
          _initialColor = startColor;
        }
        [colorValues addObject:(id)[[startColor copy] CGColor]];
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
    UIColor *endColor = [self _colorValueFromArray:keyframe[@"e"]];
    if (endColor) {
      [colorValues addObject:(id)[[endColor copy] CGColor]];
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
      outColor = startColor;
      addStartValue = YES;
      addTimePadding = YES;
    }
  }

  _animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
  _animation.values = colorValues;
  _animation.keyTimes = keyTimes;
  _animation.timingFunctions = timingFunctions;
  _animation.beginTime = beginTime;
  _animation.duration = durationTime;
  _animation.fillMode = kCAFillModeForwards;
}

- (UIColor *)_colorValueFromArray:(NSArray<NSNumber *>  *)colorArray {
  if (colorArray.count == 4) {
    return [UIColor colorWithRed:colorArray[0].floatValue / 255.f
                           green:colorArray[1].floatValue / 255.f
                            blue:colorArray[2].floatValue / 255.f
                           alpha:colorArray[3].floatValue / 255.f];
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
