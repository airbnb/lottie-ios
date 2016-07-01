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

- (instancetype)initWithShapeValues:(NSDictionary *)shapeValues
                            keyPath:(NSString *)keyPath
                          frameRate:(NSNumber *)frameRate
                         closedPath:(BOOL)closedPath {
  self = [super init];
  if (self) {
    _keyPath = [keyPath copy];
    id value = shapeValues[@"k"];
    if ([value isKindOfClass:[NSArray class]] &&
        [[(NSArray *)value firstObject] isKindOfClass:[NSDictionary class]] &&
        [(NSDictionary *)[(NSArray *)value firstObject] objectForKey:@"t"]) {
      //Keframes
      [self _buildAnimationForKeyframes:value keyPath:keyPath frameRate:frameRate closedPath:closedPath];
    } else {
      //Single Value, no animation
      _initialShape = [self _bezierShapeFromValue:value closedPath:closedPath];
    }
  }
  return self;
}

- (void)_buildAnimationForKeyframes:(NSArray<NSDictionary *> *)keyframes
                            keyPath:(NSString *)keyPath
                          frameRate:(NSNumber *)frameRate
                         closedPath:(BOOL)closedPath {
  NSMutableArray *keyTimes = [NSMutableArray array];
  NSMutableArray *timingFunctions = [NSMutableArray array];
  NSMutableArray *shapeValues = [NSMutableArray array];
  
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
  UIBezierPath *outShape = nil;
  
  for (NSDictionary *keyframe in keyframes) {
    // Get keyframe time value
    NSNumber *frame = keyframe[@"t"];
    // Calculate percentage value for keyframe.
    //CA Animations accept time values of 0-1 as a percentage of animation completed.
    NSNumber *timePercentage = @((frame.floatValue - startFrame.floatValue) / durationFrames.floatValue);
    
    if (outShape) {
      //add out value
      [shapeValues addObject:(id)[[outShape copy] CGPath]];
      [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
      outShape = nil;
    }
    
    UIBezierPath *startShape = [self _bezierShapeFromValue:keyframe[@"s"] closedPath:closedPath];
    if (addStartValue) {
      // Add start value
      if (startShape) {
        if (keyframe == keyframes.firstObject) {
          _initialShape = startShape;
        }
        
        [shapeValues addObject:(id)[[startShape copy] CGPath]];
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
    UIBezierPath *endShape = [self _bezierShapeFromValue:keyframe[@"e"] closedPath:closedPath];
    if (endShape) {
      [shapeValues addObject:(id)[[endShape copy] CGColor]];
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
      outShape = startShape;
      addStartValue = YES;
      addTimePadding = YES;
    }
  }
  
  _animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
  _animation.values = shapeValues;
  _animation.keyTimes = keyTimes;
  _animation.timingFunctions = timingFunctions;
  _animation.beginTime = beginTime;
  _animation.duration = durationTime;
  _animation.fillMode = kCAFillModeForwards;
}

- (UIBezierPath *)_bezierShapeFromValue:(id)value closedPath:(BOOL)closedPath {
  NSDictionary *pointsData = nil;
  if ([value isKindOfClass:[NSArray class]] &&
      [[(NSArray *)value firstObject] isKindOfClass:[NSDictionary class]] &&
      [(NSDictionary *)[(NSArray *)value firstObject] objectForKey:@"v"]) {
    pointsData = [(NSArray *)value firstObject];
  } else if ([value isKindOfClass:[NSDictionary class]] &&
             [(NSDictionary *)value objectForKey:@"v"]) {
    pointsData = value;
  }
  if (!pointsData) {
    return nil;
  }
  NSArray *pointsArray = pointsData[@"v"];
  NSArray *inTangents = pointsData[@"i"];
  NSArray *outTangents = pointsData[@"o"];
  
  NSAssert((pointsArray.count == inTangents.count &&
            pointsArray.count == outTangents.count),
           @"Lotte: Incorrect number of points and tangents");
  
  UIBezierPath *shape = [UIBezierPath bezierPath];
  
  [shape moveToPoint:[self _vertexAtIndex:0 inArray:pointsArray]];
  
  for (int i = 1; i < pointsArray.count; i ++) {
    [shape addCurveToPoint:[self _vertexAtIndex:i inArray:pointsArray]
            controlPoint1:[self _vertexAtIndex:i - 1 inArray:outTangents]
            controlPoint2:[self _vertexAtIndex:i inArray:inTangents]];
  }
  
  if (closedPath) {
    [shape addCurveToPoint:[self _vertexAtIndex:0 inArray:pointsArray]
            controlPoint1:[self _vertexAtIndex:pointsArray.count - 1 inArray:outTangents]
            controlPoint2:[self _vertexAtIndex:0 inArray:inTangents]];
    [shape closePath];
  }
  
  return shape;
}

- (CGPoint)_vertexAtIndex:(NSInteger)idx inArray:(NSArray *)points {
  NSAssert((idx < points.count),
           @"Lotte: Vertex Point out of bounds");
  
  NSArray *pointArray = points[idx];
  
  NSAssert((pointArray.count >= 2 &&
           [pointArray.firstObject isKindOfClass:[NSNumber class]]),
           @"Lotte: Point Data Malformed");
  
  return CGPointMake([pointArray[0] floatValue], [pointArray[1] floatValue]);
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
