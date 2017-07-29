//
//  LOTShapePath.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTShapePath.h"

@implementation LOTShapePath

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {
  _index = jsonDictionary[@"ind"];
  _closed = [jsonDictionary[@"closed"] boolValue];
  NSDictionary *shape = jsonDictionary[@"ks"];
  if (shape) {
    _shapePath = [[LOTKeyframeGroup alloc] initWithData:shape];
  }
}

@end
