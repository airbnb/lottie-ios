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

@interface LOTTextDocument : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary;

@property (nonatomic, strong, nonnull) NSArray<LOTTextDocumentKeyframe*> * keyframes;

@end

@interface LOTTextDocumentKeyframe : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary;

@property (nonatomic, readonly) NSNumber * keyframeTime;
@property (nonatomic, readonly) NSString * fontName;
@property (nonatomic, readonly) UIColor * fontColor;
@property (nonatomic, readonly) NSString * justification;
@property (nonatomic, readonly) NSNumber * lineHeight;
@property (nonatomic, readonly) NSString * fontSize;
@property (nonatomic, readonly) NSString * text;
@property (nonatomic, readonly) NSNumber * tracking;

@end
