//
//  LOTTextAnimations.h
//  Lottie
//
//  Created by Adam Tierney on 4/18/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LOTKeyframeGroup;

@interface LOTTextAnimations : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary;

@property (nonatomic, readonly) LOTKeyframeGroup * fillColor;
@property (nonatomic, readonly) LOTKeyframeGroup * strokeColor;
@property (nonatomic, readonly) LOTKeyframeGroup * strokeWidth;
@property (nonatomic, readonly) LOTKeyframeGroup * tracking;

@end
