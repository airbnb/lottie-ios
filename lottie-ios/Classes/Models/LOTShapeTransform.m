//
//  LOTShapeTransform.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTShapeTransform.h"
#import "LOTAnimatableNumberValue.h"
#import "LOTAnimatablePointValue.h"
#import "LOTAnimatableScaleValue.h"
#import "LOTHelpers.h"

@implementation LOTShapeTransform

+ (instancetype)transformIdentityWithCompBounds:(CGRect)compBounds {
  NSDictionary *transformIdentity = @{@"p" : @{@"k" : @[@0, @0]},
                                      @"a" : @{@"k" : @[@0, @0]},
                                      @"s" : @{@"k" : @[@100, @100]},
                                      @"r" : @{@"k" : @[@0]},
                                      @"o" : @{@"k" : @[@100]}};
  
  
  return [[LOTShapeTransform alloc] initWithJSON:transformIdentity frameRate:@60 compBounds:compBounds];
}

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate compBounds:compBounds];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds {
  _compBounds = compBounds;
  
  NSDictionary *position = jsonDictionary[@"p"];
  if (position) {
    _position = [[LOTAnimatablePointValue alloc] initWithPointValues:position frameRate:frameRate];
  }
  
  NSDictionary *anchor = jsonDictionary[@"a"];
  if (anchor) {
    _anchor = [[LOTAnimatablePointValue alloc] initWithPointValues:anchor frameRate:frameRate];
    [_anchor remapPointsFromBounds:compBounds toBounds:CGRectMake(0, 0, 1, 1)];
    _anchor.usePathAnimation = NO;
  }
  
  NSDictionary *scale = jsonDictionary[@"s"];
  if (scale) {
    _scale = [[LOTAnimatableScaleValue alloc] initWithScaleValues:scale frameRate:frameRate];
  }
  
  NSDictionary *rotation = jsonDictionary[@"r"];
  if (rotation) {
    _rotation = [[LOTAnimatableNumberValue alloc] initWithNumberValues:rotation frameRate:frameRate];
    [_rotation remapValueWithBlock:^CGFloat(CGFloat inValue) {
      return LOT_DegreesToRadians(inValue);
    }];
  }
  
  NSDictionary *opacity = jsonDictionary[@"o"];
  if (opacity) {
    _opacity = [[LOTAnimatableNumberValue alloc] initWithNumberValues:opacity frameRate:frameRate];
    [_opacity remapValuesFromMin:@0 fromMax:@100 toMin:@0 toMax:@1];
  }
}

- (NSString *)description {
  return [NSString stringWithFormat:@"LOTShapeTransform \"Position: %@ Anchor: %@ Scale: %@ Rotation: %@ Opacity: %@\"", _position.description, _anchor.description, _scale.description, _rotation.description, _opacity.description];
}

@end
