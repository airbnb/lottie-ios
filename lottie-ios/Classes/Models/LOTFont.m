//
//  LOTFont.m
//  Lottie
//
//  Created by Adam Tierney on 5/4/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import "LOTFont.h"

@implementation LOTFont

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {

  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {
  _name = jsonDictionary[@"fName"];
  _familyName = jsonDictionary[@"fFamily"];
  _style = jsonDictionary[@"fStyle"];
  _ascent = jsonDictionary[@"ascent"];
}

@end
