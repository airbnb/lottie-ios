//
//  LOTShapePath.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTShapePath.h"
#import "LOTAnimatableShapeValue.h"

@implementation LOTShapePath

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary frameRate:frameRate];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate {
  _index = jsonDictionary[@"ind"];
  _closed = [jsonDictionary[@"closed"] boolValue];
  NSDictionary *shape = jsonDictionary[@"ks"];
  if (shape) {
    _shapePath = [[LOTAnimatableShapeValue alloc] initWithShapeValues:shape frameRate:frameRate closed:_closed];
  }
}

@end
