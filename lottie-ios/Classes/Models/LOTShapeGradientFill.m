//
//  LOTShapeGradientFill.m
//  Lottie
//
//  Created by brandon_withrow on 7/26/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTShapeGradientFill.h"
#import "LOTAnimatablePointValue.h"
#import "LOTAnimatableNumberValue.h"
#import "LOTAnimatableColorValue.h"
#import "CGGeometry+LOTAdditions.h"

@implementation LOTShapeGradientFill

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  NSNumber *type = jsonDictionary[@"t"];
  if (type.integerValue != 1) {
    NSLog(@"%s: Warning: Only Linear Gradients are supported.", __PRETTY_FUNCTION__);
  }
  
  NSDictionary *start = jsonDictionary[@"s"];
  if (start) {
    _startPoint = [[LOTAnimatablePointValue alloc] initWithPointValues:start frameRate:frameRate];
  }
  
  NSDictionary *end = jsonDictionary[@"e"];
  if (end) {
    _endPoint = [[LOTAnimatablePointValue alloc] initWithPointValues:end frameRate:frameRate];
  }
  
  NSDictionary *gradient = jsonDictionary[@"g"];
  if (gradient) {
    NSDictionary *unwrappedGradient = gradient[@"k"];
    _numberOfColors = gradient[@"p"];
    _gradient = [[LOTAnimatableNumberValue alloc] initWithNumberValues:unwrappedGradient frameRate:frameRate];
  }
  
  NSDictionary *opacity = jsonDictionary[@"o"];
  if (opacity) {
    _opacity = [[LOTAnimatableNumberValue alloc] initWithNumberValues:opacity frameRate:frameRate];
    [_opacity remapValuesFromMin:@0 fromMax:@100 toMin:@0 toMax:@1];
    [_opacity.keyframeGroup remapKeyframesWithBlock:^CGFloat(CGFloat inValue) {
      return LOT_RemapValue(inValue, 0, 100, 0, 1);
    }];
  }
  
  NSNumber *evenOdd = jsonDictionary[@"r"];
  if (evenOdd.integerValue == 2) {
    _evenOddFillRule = YES;
  } else {
    _evenOddFillRule = NO;
  }
}
@end
