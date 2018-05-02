//
//  LOTText.h
//  Lottie
//
//  Created by Adam Tierney on 4/18/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LOTKeyframeGroup;
@class LOTShapeGroup;
@class LOTTextProperties;
@class LOTTextFrame;
@class LOTTextAnimations;

@interface LOTText : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary;

@property (nonatomic, readonly) LOTTextAnimations * animations;
@property (nonatomic, readonly) LOTKeyframeGroup * propertyFrames;

- (NSArray<LOTTextFrame*>*)textFramesFromKeyframes;

@end

@interface LOTTextFrame : NSObject

@property (nonatomic, readonly) LOTTextAnimations * animations;
@property (nonatomic, readonly) LOTTextProperties * properties;
@property (nonatomic, readonly) LOTKeyframeGroup * textFrameGroup;

@property (nonatomic, readonly) NSArray<LOTShapeGroup*> * frameGroups;

- (instancetype)initWithProperties:(LOTTextProperties*)properties
                     andAnimations:(LOTTextAnimations*)animations
                         fromGroup:(LOTKeyframeGroup*)group;
@end
