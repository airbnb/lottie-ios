//
//  LOTAnimationView_Internal.h
//  Lottie
//
//  Created by Brandon Withrow on 12/7/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import "LOTAnimationView.h"

typedef enum : NSUInteger {
  LOTConstraintTypeAlignToBounds,
  LOTConstraintTypeAlignToLayer,
  LOTConstraintTypeNone
} LOTConstraintType;

@interface LOTAnimationState : NSObject

- (_Nonnull instancetype)initWithDuration:(CGFloat)duration layer:( CALayer * _Nullable)layer;

- (void)setAnimationIsPlaying:(BOOL)animationIsPlaying;
- (void)setAnimationDoesLoop:(BOOL)loopAnimation;
- (void)setAnimatedProgress:(CGFloat)progress;
- (void)setAnimationSpeed:(CGFloat)speed;

@property (nonatomic, readonly) BOOL loopAnimation;
@property (nonatomic, readonly) BOOL animationIsPlaying;

// Model Properties
@property (nonatomic, readonly) CGFloat animatedProgress;
@property (nonatomic, readonly) CGFloat animationDuration;
@property (nonatomic, readonly) CGFloat animationSpeed;

@property (nonatomic, readonly) CALayer * _Nullable layer;

@end

@interface LOTAnimationView ()

@property (nonatomic, readonly) LOTComposition * _Nonnull sceneModel;
@property (nonatomic, strong) LOTAnimationState *_Nonnull animationState;
@property (nonatomic, copy, nullable) LOTAnimationCompletionBlock completionBlock;

@end
