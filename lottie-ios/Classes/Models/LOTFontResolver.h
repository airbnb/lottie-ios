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

- (void)seedGlyphPathsWithJSON:(NSArray*)charactersJSON fontsJSON:(NSArray*)fontsJSON;

- (LOTCharacter *)getGlyphForCharacter:(unichar)characterString
                                ofSize:(NSNumber*)size
                     withConjoinedName:(NSString*)familyStyleString;

@end
