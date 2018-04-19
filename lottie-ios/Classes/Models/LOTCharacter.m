//
//  LOTCharacter.m
//  Lottie
//
//  Created by Adam Tierney on 4/19/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import "LOTCharacter.h"
#import "LOTShapeGroup.h"

@implementation LOTCharacter

- (nullable instancetype)initWithJSON:(nonnull NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary*)jsonDictionary {
  _characterString = jsonDictionary[@"ch"];
  _width = jsonDictionary[@"w"];
  _fontFamilyName = jsonDictionary[@"fFamily"];
  _fontSize = jsonDictionary[@"size"];
  _fontStyle = jsonDictionary[@"style"];
  _fontFamilyName = jsonDictionary[@"fFamily"];

  NSDictionary *characterData = jsonDictionary[@"data"];
  if (characterData && characterData[@"shapes"]) {

    NSMutableArray *shapes = [NSMutableArray array];
    for (NSDictionary *shapeJSON in characterData[@"shapes"]) {
      id shapeItem = [LOTShapeGroup shapeItemWithJSON:shapeJSON];
      if (shapeItem) {
        [shapes addObject:shapeItem];
      }
    }
    _shapes = shapes;
  }
}

@end
