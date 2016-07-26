//
//  LAShapeTrimPath.m
//  LotteAnimator
//
//  Created by brandon_withrow on 7/26/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LAShapeTrimPath.h"

@implementation LAShapeTrimPath

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  NSDictionary *start = jsonDictionary[@"s"];
  if (start) {
    _start = [[LAAnimatableNumberValue alloc] initWithNumberValues:start frameRate:frameRate];
    [_start remapValuesFromMin:@0 fromMax:@100 toMin:@0 toMax:@1];
  }
  
  NSDictionary *end = jsonDictionary[@"e"];
  if (end) {
    _end = [[LAAnimatableNumberValue alloc] initWithNumberValues:end frameRate:frameRate];
    [_end remapValuesFromMin:@0 fromMax:@100 toMin:@0 toMax:@1];
  }
}

@end
