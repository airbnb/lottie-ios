//
//  LOTFontResolver.m
//  Lottie
//
//  Created by Adam Tierney on 4/19/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import "LOTFontResolver.h"
#import "LOTCharacter.h"
#import "LOTHelpers.h"

@implementation LOTFontResolver {
  NSMutableDictionary <NSString *, LOTCharacter *> * _characterMap;
}

// TODO: probably don't use a singleton and scope this to animation
+ (instancetype)shared {
  static LOTFontResolver * _sharedResolver;
  if (!_sharedResolver) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      _sharedResolver = [[LOTFontResolver alloc] init];
    });
  }
  return _sharedResolver;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _characterMap = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)seedGlyphPathsWithJSON:(NSArray*)charactersJSON {
  for (NSDictionary *characterJSON in charactersJSON) {
    LOTCharacter *character = [[LOTCharacter alloc] initWithJSON:characterJSON];
    if (character) {
      [self setCharacter:character];
    }
  }

  NSLog(@"imported glyphs %@", _characterMap);
}

- (void)setCharacter:(nonnull LOTCharacter*)character {
  NSString *key = [LOTFontResolver keyForCharacterString:character.characterString
                                                  ofSize:character.fontSize
                                          fromFontFamily:character.fontFamilyName
                                                 inStyle:character.fontStyle];
  if (key) {
    _characterMap[key] = character;
  }
}

- (LOTCharacter *)getCharacterWithString:(NSString*)characterString
                                  ofSize:(NSNumber*)size
                          fromFontFamily:(NSString*)family
                                 inStyle:(NSString*)style {

  NSString *key = [LOTFontResolver keyForCharacterString:characterString ofSize:size fromFontFamily:family inStyle:style];
  LOTCharacter *lotCharacter = _characterMap[key];
  if (!lotCharacter) {
    NSLog(@"%@ not present for key %@ – be sure to export the character as a glyph or provide a custom font file", characterString, key);
  }

  return lotCharacter;
}

- (LOTCharacter *)getCharacter:(unichar)character
                        ofSize:(NSNumber*)size
                fromFontFamily:(NSString*)family
                       inStyle:(NSString*)style {

  NSString *key = [LOTFontResolver keyForCharacter:character ofSize:size fromFontFamily:family inStyle:style];
  LOTCharacter *lotCharacter = _characterMap[key];
  if (!lotCharacter) {
    NSLog(@"%C not present for key %@ – be sure to export the character as a glyph or provide a custom font file", character, key);
  }

  return lotCharacter;
}

+ (NSString *)keyForCharacterString:(NSString*)characterString
                             ofSize:(NSNumber*)size
                     fromFontFamily:(NSString*)family
                            inStyle:(NSString*)style {

  NSRange range = [characterString rangeOfComposedCharacterSequenceAtIndex:0];

  // assume a UTF-16 character, this cue is taken from Android, could probably be relaxed if preferred
  if (range.length != 1) {
    NSLog(@"requesting character key with an invalid character string: %@", characterString);
    return nil;
  }

  unichar characterValue = [characterString characterAtIndex:0];
  NSString *key = [LOTFontResolver keyForCharacter:characterValue
                                            ofSize:size
                                    fromFontFamily:family
                                           inStyle:style];
  return key;
}

+ (NSString *)keyForCharacter:(unichar)character
                       ofSize:(NSNumber*)size
               fromFontFamily:(NSString*)family
                      inStyle:(NSString*)style {
  //FIXME: reconcile two different spellings for chars and doc
//  return [NSString stringWithFormat: @"%@-%@-%C", family, size, character];
  return [NSString stringWithFormat: @"%C", character];
}

@end
