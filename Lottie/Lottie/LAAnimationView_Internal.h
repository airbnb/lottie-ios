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

- (id)initWithDuration:(CGFloat)duration layer:(CALayer *)layer;

- (void)updateAnimationLayer;

- (void)setAnimationIsPlaying:(BOOL)animationIsPlaying;
- (void)setAnimationDoesLoop:(BOOL)loopAnimation;
- (void)setAnimatedProgress:(CGFloat)progress;
- (void)setAnimationSpeed:(CGFloat)speed;

@property (nonatomic, readonly) BOOL loopAnimation;
@property (nonatomic, readonly) BOOL animationIsPlaying;

@property (nonatomic, readonly) CFTimeInterval startTimeAbsolute;
@property (nonatomic, readonly) CFTimeInterval pauseTimeAbsolute;

// Model Properties
@property (nonatomic, readonly) CGFloat animatedProgress;
@property (nonatomic, readonly) CGFloat animationDuration;
@property (nonatomic, readonly) CGFloat animationSpeed;

// CA Layer Properties
@property (nonatomic, readonly) CFTimeInterval layerBeginTime;
@property (nonatomic, readonly) CFTimeInterval layerTimeOffset;
@property (nonatomic, readonly) CGFloat layerSpeed;

@property (nonatomic, readonly) CALayer *layer;

@end

@interface LAAnimationView ()

@property (nonatomic, readonly) LAComposition *sceneModel;
@property (nonatomic, strong) LAAnimationState *animationState;
@property (nonatomic, copy, nullable) LAAnimationCompletionBlock completionBlock;

@end
