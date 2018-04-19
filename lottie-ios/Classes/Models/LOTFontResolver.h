//
//  LOTFontResolver.h
//  Lottie
//
//  Created by Adam Tierney on 4/19/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LOTCharacter;

@interface LOTFontResolver : NSObject

+ (instancetype)shared;

- (void)seedGlyphPathsWithJSON:(NSArray*)charactersJSON;

- (LOTCharacter *)getCharacter:(unichar)character
                        ofSize:(NSNumber*)size
                fromFontFamily:(NSString*)family
                       inStyle:(NSString*)style;

- (LOTCharacter *)getCharacterWithString:(NSString*)characterString
                                  ofSize:(NSNumber*)size
                          fromFontFamily:(NSString*)family
                                 inStyle:(NSString*)style;
@end
