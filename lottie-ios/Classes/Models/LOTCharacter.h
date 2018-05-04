//
//  LOTCharacter.h
//  Lottie
//
//  Created by Adam Tierney on 4/19/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LOTShapeGroup;

@interface LOTCharacter : NSObject

- (nullable instancetype)initWithJSON:(nonnull NSDictionary *)jsonDictionary;

@property (nonatomic, readonly) NSString * characterString;
@property (nonatomic, readonly) NSNumber * width;
@property (nonatomic, readonly) NSString * fontFamilyName;
@property (nonatomic, readonly) NSNumber * fontSize;
@property (nonatomic, readonly) NSString * fontStyle;
@property (nonatomic, readonly) LOTShapeGroup * shapes;

@end
