//
//  LOTFont.h
//  Lottie
//
//  Created by Adam Tierney on 5/4/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LOTFont : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary;

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* familyName;
@property (nonatomic, readonly) NSString* style;
@property (nonatomic, readonly) NSNumber* ascent;

@end
