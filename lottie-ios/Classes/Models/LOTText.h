//
//  LOTTextDocument.h
//  Lottie
//
//  Created by Adam Tierney on 4/18/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTPlatformCompat.h"

@class LOTTextDocumentKeyframe;
@class LOTTextAnimations;
@class LOTCharacter;

@interface LOTText : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary;

@property (nonatomic, readonly) LOTTextAnimations * animations;
@property (nonatomic, readonly) NSArray<LOTTextDocumentKeyframe*> * keyframes;

@end

@interface LOTTextDocumentKeyframe : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary;

@property (nonatomic, readonly) NSString * text;
@property (nonatomic, readonly) NSArray<LOTCharacter*> * characters;
@property (nonatomic, readonly) NSNumber * keyframeTime;
@property (nonatomic, readonly) NSString * fontName;
@property (nonatomic, readonly) UIColor  * fontColor;
@property (nonatomic, readonly) UIColor  * strokeColor;
@property (nonatomic, readonly) NSNumber * strokeWidth;
@property (nonatomic, readonly) NSString * justification;
@property (nonatomic, readonly) NSNumber * lineHeight;
@property (nonatomic, readonly) NSNumber * fontSize;
@property (nonatomic, readonly) NSNumber * tracking;
@property (nonatomic, readonly) BOOL strokeOverfill;

@end
