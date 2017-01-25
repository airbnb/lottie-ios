//
//  LAAnimationView_Internal.h
//  Lottie
//
//  Created by Brandon Withrow on 12/7/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

typedef enum : NSUInteger {
  LAConstraintTypeAlignToBounds,
  LAConstraintTypeAlignToLayer,
  LAConstraintTypeNone
} LAConstraintType;

@interface LAAnimationState : NSObject

- (instancetype)initWithDuration:(CGFloat)duration layer:(CALayer *)layer;

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

@property (nonatomic, readonly) CALayer *layer;

@end

@interface LAAnimationView ()

@property (nonatomic, readonly) LAComposition *sceneModel;
@property (nonatomic, strong) LAAnimationState *animationState;
@property (nonatomic, copy, nullable) LAAnimationCompletionBlock completionBlock;

@end
