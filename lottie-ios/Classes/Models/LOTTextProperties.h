//
//  LOTTextProperties.h
//  Lottie
//
//  Created by Adam Tierney on 5/2/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTPlatformCompat.h"

@class LOTCharacter;

@interface LOTTextProperties : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary;

@property (nonatomic, readonly) NSString * text;
@property (nonatomic, readonly) NSArray<LOTCharacter*> * characters;
@property (nonatomic, readonly) NSNumber * keyframeTime;
@property (nonatomic, readonly) NSString * fontName;
@property (nonatomic, readonly) UIColor  * fontColor;
@property (nonatomic, readonly) UIColor  * strokeColor;
@property (nonatomic, readonly) NSNumber * strokeWidth;
@property (nonatomic, readonly) NSNumber * justification;
@property (nonatomic, readonly) NSNumber * lineHeight;
@property (nonatomic, readonly) NSNumber * fontSize;
@property (nonatomic, readonly) NSNumber * tracking;
@property (nonatomic, readonly) BOOL strokeOverfill;

@end
