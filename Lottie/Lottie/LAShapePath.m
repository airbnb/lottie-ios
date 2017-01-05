//
//  LAShapePath.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapePath.h"
#import "LAAnimatableShapeValue.h"

@implementation LAShapePath

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
    _shapePath = [[LAAnimatableShapeValue alloc] initWithShapeValues:shape frameRate:frameRate closed:_closed];
  }
}

@end
