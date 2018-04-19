//
//  LOTText.m
//  Lottie
//
//  Created by Adam Tierney on 4/18/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import "LOTText.h"
#import "LOTTextAnimations.h"
#import "LOTCharacter.h"
#import "LOTFontResolver.h"
#import "UIColor+Expanded.h"

@implementation LOTText

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {

  // Animations:
  // This is an array, but we're only concerned with the first item. This cue is taken from the
  // Android implementation but may have a better reason we can note here:
  NSDictionary *textAnimationsJSON = [jsonDictionary[@"a"] firstObject];
  _animations = [[LOTTextAnimations alloc] initWithJSON:textAnimationsJSON];

  // Document
  NSDictionary *documentJSON = jsonDictionary[@"d"];
  NSArray *keyframesJSON = documentJSON[@"k"];
  NSMutableArray *keyframes = [NSMutableArray array];
  for (NSDictionary *keyframeJSON in keyframesJSON) {
    id newKeyframe = [[LOTTextDocumentKeyframe alloc] initWithJSON:keyframeJSON];
    if (newKeyframe) {
      [keyframes addObject:newKeyframe];
    }
  }
  _keyframes = keyframes;
}

@end

@implementation LOTTextDocumentKeyframe

@synthesize characters = _characters;

- (NSArray<LOTCharacter *> *)characters {
  if (!_characters) {
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
    _characters = arr;
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
  _keyframeTime = jsonDictionary[@"t"];
  NSDictionary *documentInfo = jsonDictionary[@"s"];
  _fontName = documentInfo[@"f"];
  _justification = documentInfo[@"j"];
  _lineHeight = documentInfo[@"lh"];
  _fontSize = documentInfo[@"s"];
  _text = documentInfo[@"t"];
  _tracking = documentInfo[@"tr"];
  _fontColor = [UIColor LOT_colorFromRGBAArray:documentInfo[@"fc"]];
  _strokeColor = [UIColor LOT_colorFromRGBAArray:documentInfo[@"sc"]];
  _strokeWidth = documentInfo[@"sw"];
  _strokeOverfill = [documentInfo[@"of"] boolValue];

}

@end
