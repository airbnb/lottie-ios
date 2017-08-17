//
//  LOTAnimationView
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LOTAnimationView_Compat.h"
#import "LOTComposition.h"

typedef void (^LOTAnimationCompletionBlock)(BOOL animationFinished);

@interface LOTAnimationView : LOTView

/// Load animation by name from the default bundle, Images are also loaded from the bundle
+ (nonnull instancetype)animationNamed:(nonnull NSString *)animationName NS_SWIFT_NAME(init(name:));

/// Loads animation by name from specified bundle, Images are also loaded from the bundle
+ (nonnull instancetype)animationNamed:(nonnull NSString *)animationName inBundle:(nonnull NSBundle *)bundle NS_SWIFT_NAME(init(name:bundle:));

/// Creates an animation from the deserialized JSON Dictionary
+ (nonnull instancetype)animationFromJSON:(nonnull NSDictionary *)animationJSON NS_SWIFT_NAME(init(json:));

/// Loads an animation from a specific file path. WARNING Do not use a web URL for file path.
+ (nonnull instancetype)animationWithFilePath:(nonnull NSString *)filePath NS_SWIFT_NAME(init(filePath:));

/// Creates an animation from the deserialized JSON Dictionary, images are loaded from the specified bundle
+ (nonnull instancetype)animationFromJSON:(nullable NSDictionary *)animationJSON inBundle:(nullable NSBundle *)bundle NS_SWIFT_NAME(init(json:bundle:));

/// Creates an animation from the LOTComposition, images are loaded from the specified bundle
- (nonnull instancetype)initWithModel:(nullable LOTComposition *)model inBundle:(nullable NSBundle *)bundle;

/// Loads animation asynchrounously from the specified URL
- (nonnull instancetype)initWithContentsOfURL:(nonnull NSURL *)url;

/// Flag is YES when the animation is playing
@property (nonatomic, readonly) BOOL isAnimationPlaying;

/// Tells the animation to loop indefinitely.
@property (nonatomic, assign) BOOL loopAnimation;

/// The animation will play forward and then backwards if loopAnimation is also YES
@property (nonatomic, assign) BOOL autoReverseAnimation;

/// Sets a progress from 0 - 1 of the animation. If the animation is playing it will stop and the compeltion block will be called.
/// The current progress of the animation in absolute time.
/// e.g. a value of 0.75 always represents the same point in the animation, regardless of positive
/// or negative speed.
@property (nonatomic, assign) CGFloat animationProgress;

/// Sets the speed of the animation. Accepts a negative value for reversing animation.
@property (nonatomic, assign) CGFloat animationSpeed;

/// Read only of the duration in seconds of the animation at speed of 1
@property (nonatomic, readonly) CGFloat animationDuration;

/// Enables or disables caching of the backing animation model. Defaults to YES
@property (nonatomic, assign) BOOL cacheEnable;

/// Sets a completion block to call when the animation has completed
@property (nonatomic, copy, nullable) LOTAnimationCompletionBlock completionBlock;

/// Set the amimation data
@property (nonatomic, strong, nonnull) LOTComposition *sceneModel;

/* 
 * Plays the animation from its current position to a specific progress. 
 * The animation will start from its current position.
 * If loopAnimation is YES the animation will loop from start position to toProgress indefinitely.
 * If loopAnimation is NO the animation will stop and the comletion block will be called.
 */
- (void)playToProgress:(CGFloat)toProgress
        withCompletion:(nullable LOTAnimationCompletionBlock)completion;

/*
 * Plays the animation from specific progress to a specific progress
 * The animation will start from its current position..
 * If loopAnimation is YES the animation will loop from the startProgress to the endProgress indefinitely
 * If loopAnimation is NO the animation will stop and the comletion block will be called.
 */
- (void)playFromProgress:(CGFloat)fromStartProgress
              toProgress:(CGFloat)toEndProgress
          withCompletion:(nullable LOTAnimationCompletionBlock)completion;

/*
 * Plays the animation from its current position to a specific frame.
 * The animation will start from its current position.
 * If loopAnimation is YES the animation will loop from beginning to toFrame indefinitely.
 * If loopAnimation is NO the animation will stop and the comletion block will be called.
 */
- (void)playToFrame:(nonnull NSNumber *)toFrame
     withCompletion:(nullable LOTAnimationCompletionBlock)completion;

/*
 * Plays the animation from specific frame to a specific frame. 
 * The animation will start from its current position.
 * If loopAnimation is YES the animation will loop start frame to end frame indefinitely.
 * If loopAnimation is NO the animation will stop and the comletion block will be called.
 */
- (void)playFromFrame:(nonnull NSNumber *)fromStartFrame
              toFrame:(nonnull NSNumber *)toEndFrame
       withCompletion:(nullable LOTAnimationCompletionBlock)completion;


/**
 * Plays the animation from its current position to the end of the animation.
 * The animation will start from its current position.
 * If loopAnimation is YES the animation will loop from beginning to end indefinitely.
 * If loopAnimation is NO the animation will stop and the comletion block will be called.
 **/
- (void)playWithCompletion:(nullable LOTAnimationCompletionBlock)completion;

/// Plays the animaiton
- (void)play;

/// Stops the animation at the current frame. The completion block will be called.
- (void)pause;

/// Stops the animation and rewinds to the beginning. The completion block will be called.
- (void)stop;

/// Sets progress of animation to a specific frame. If the animation is playing it will stop and the completion block will be called.
- (void)setProgressWithFrame:(nonnull NSNumber *)currentFrame;

/**
 * Sets the keyframe value for a specific After Effects property at a given time.
 * @param value id
 * Value is the color, point, or number object that should be set at given time
 *
 * @param keypath NSString . separate keypath
 * The Keypath is a dot seperated key path that specifies the location of the key to
 * be set from the After Effects file. This will begin with the Layer Name.
 * EG "Layer 1.Shape 1.Fill 1.Color" 
 *
 * @param frame
 * The frame is the frame to be set. 
 * If the keyframe exists it will be overwritten, if it does not exist a new 
 * Linearlly interpolated keyframe will be added
 **/
- (void)setValue:(nonnull id)value
      forKeypath:(nonnull NSString *)keypath
         atFrame:(nullable NSNumber *)frame;

/// Logs all child keypaths
- (void)logHierarchyKeypaths;

/**
 * Adds a custom subview to the animation using a LayerName from After Effects 
 * as a reference point.
 *
 * @param view The custom view instance to be added
 *
 * @param layer The string name of the After Effects layer to be referenced.
 *
 * @param applyTransform If YES the custom view will be animated to move with the 
 * specified After Effects layer.
 * If NO the custom view will be masked by the After Effects layer
 **/
- (void)addSubview:(nonnull LOTView *)view
      toLayerNamed:(nonnull NSString *)layer
    applyTransform:(BOOL)applyTransform;

#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
@property (nonatomic) LOTViewContentMode contentMode;
#endif

@end
