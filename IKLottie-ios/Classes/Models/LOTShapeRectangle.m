//
//  LOTShapeRectangle.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTShapeRectangle.h"
#import "LOTAnimatableBoundsValue.h"
#import "LOTAnimatablePointValue.h"
#import "LOTAnimatableNumberValue.h"

@implementation LOTShapeRectangle

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  NSDictionary *position = jsonDictionary[@"p"];
  if (position) {
    _position = [[LOTAnimatablePointValue alloc] initWithPointValues:position frameRate:frameRate];
    _position.usePathAnimation = NO;
  }
  
  NSDictionary *cornerRadius = jsonDictionary[@"r"];
  if (cornerRadius) {
    _cornerRadius = [[LOTAnimatableNumberValue alloc] initWithNumberValues:cornerRadius frameRate:frameRate];
  }
  
  NSDictionary *size = jsonDictionary[@"s"];
  if (size) {
    _size = [[LOTAnimatablePointValue alloc] initWithPointValues:size frameRate:frameRate];
  }
}

@end
