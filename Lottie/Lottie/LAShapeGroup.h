//
//  LAShape.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LAShapeGroup : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds;

@property (nonatomic, readonly) NSArray *items;

+ (id)shapeItemWithJSON:(NSDictionary *)itemJSON frameRate:(NSNumber *)frameRate compBounds:(CGRect)compBounds;

@end
