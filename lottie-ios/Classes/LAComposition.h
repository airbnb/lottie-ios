//
//  LAScene.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LALayer;

@interface LAComposition : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary;

@property (nonatomic, readonly) NSArray <LALayer *> *layers;
@property (nonatomic, readonly) CGRect compBounds;
@property (nonatomic, readonly) NSNumber *startFrame;
@property (nonatomic, readonly) NSNumber *endFrame;
@property (nonatomic, readonly) NSNumber *framerate;
@property (nonatomic, readonly) NSTimeInterval timeDuration;

- (LALayer *)layerModelForID:(NSNumber *)layerID;

@end
