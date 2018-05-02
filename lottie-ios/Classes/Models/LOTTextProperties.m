//
//  LOTTextProperties.m
//  Lottie
//
//  Created by Adam Tierney on 5/2/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import "LOTTextProperties.h"
#import "LOTCharacter.h"
#import "LOTFontResolver.h"
#import "UIColor+Expanded.h"

@implementation LOTTextProperties

@synthesize characters = _characters;

- (NSArray<LOTCharacter *> *)characters {
  if (!_characters) {
    _characters = [self newCharacters];
  }
  return _characters;
}

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {
  _fontName = jsonDictionary[@"f"];
  _justification = jsonDictionary[@"j"];
  _lineHeight = jsonDictionary[@"lh"];
  _fontSize = jsonDictionary[@"s"];
  _text = jsonDictionary[@"t"];
  _tracking = jsonDictionary[@"tr"];
  _fontColor = [UIColor LOT_colorFromRGBAArray:jsonDictionary[@"fc"]];
  _strokeColor = [UIColor LOT_colorFromRGBAArray:jsonDictionary[@"sc"]];
  _strokeWidth = jsonDictionary[@"sw"];
  _strokeOverfill = [jsonDictionary[@"of"] boolValue];
}

- (NSArray<LOTCharacter *>*)newCharacters {
  NSMutableArray *arr = [NSMutableArray array];
  NSUInteger length = [self.text length];
  unichar buffer[length];

  [self.text getCharacters:buffer range:NSMakeRange(0, length)];
  for (int i=0; i<length; i++) {

    LOTCharacter *glyph = [[LOTFontResolver shared] getCharacter:buffer[i]
                                                          ofSize:self.fontSize
                                                  fromFontFamily:self.fontName
                                                         inStyle:@"foo"];
    if (glyph) {
      [arr addObject:glyph];
    }
  }

  return arr;
}

@end
