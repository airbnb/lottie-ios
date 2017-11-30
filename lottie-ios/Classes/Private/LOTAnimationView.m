//
//  LOTAnimationView
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTAnimationView.h"
#import "LOTPlatformCompat.h"
#import "LOTModels.h"
#import "LOTHelpers.h"
#import "LOTAnimationView_Internal.h"
#import "LOTAnimationCache.h"
#import "LOTCompositionContainer.h"

static NSString * const kCompContainerAnimationKey = @"play";

@implementation LOTAnimationView {
  LOTCompositionContainer *_compContainer;
  NSNumber *_playRangeStartFrame;
  NSNumber *_playRangeEndFrame;
  CGFloat _playRangeStartProgress;
  CGFloat _playRangeEndProgress;
  NSBundle *_bundle;
  CGFloat _animationProgress;

  // Properties for tracking automatic restoration of animation.
  BOOL _shouldRestoreStateWhenAttachedToWindow;
  LOTAnimationCompletionBlock _completionBlockToRestoreWhenAttachedToWindow;
}

# pragma mark - Convenience Initializers

+ (nonnull instancetype)animationNamed:(nonnull NSString *)animationName {
  return [self animationNamed:animationName inBundle:[NSBundle mainBundle]];
}

+ (nonnull instancetype)animationNamed:(nonnull NSString *)animationName inBundle:(nonnull NSBundle *)bundle {
  LOTComposition *comp = [LOTComposition animationNamed:animationName inBundle:bundle];
  return [[LOTAnimationView alloc] initWithModel:comp inBundle:bundle];
}

+ (nonnull instancetype)animationFromJSON:(nonnull NSDictionary *)animationJSON {
    return [self animationFromJSON:animationJSON inBundle:[NSBundle mainBundle]];
}

+ (nonnull instancetype)animationFromJSON:(nullable NSDictionary *)animationJSON inBundle:(nullable NSBundle *)bundle {
  LOTComposition *comp = [LOTComposition animationFromJSON:animationJSON inBundle:bundle];
  return [[LOTAnimationView alloc] initWithModel:comp inBundle:bundle];
}

+ (nonnull instancetype)animationWithFilePath:(nonnull NSString *)filePath {
  LOTComposition *comp = [LOTComposition animationWithFilePath:filePath];
  return [[LOTAnimationView alloc] initWithModel:comp inBundle:[NSBundle mainBundle]];
}

# pragma mark - Initializers

- (instancetype)initWithContentsOfURL:(NSURL *)url {
  self = [super initWithFrame:CGRectZero];
  if (self) {
    [self _commonInit];
    LOTComposition *laScene = [[LOTAnimationCache sharedCache] animationForKey:url.absoluteString];
    if (laScene) {
      laScene.cacheKey = url.absoluteString;
      [self _initializeAnimationContainer];
      [self _setupWithSceneModel:laScene];
    } else {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSData *animationData = [NSData dataWithContentsOfURL:url];
        if (!animationData) {
          return;
        }
        NSError *error;
        NSDictionary  *animationJSON = [NSJSONSerialization JSONObjectWithData:animationData
                                                                       options:0 error:&error];
        if (error || !animationJSON) {
          return;
        }
        
        LOTComposition *laScene = [[LOTComposition alloc] initWithJSON:animationJSON withAssetBundle:[NSBundle mainBundle]];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
          [[LOTAnimationCache sharedCache] addAnimation:laScene forKey:url.absoluteString];
          laScene.cacheKey = url.absoluteString;
          [self _initializeAnimationContainer];
          [self _setupWithSceneModel:laScene];
        });
      });
    }
  }
  return self;
}

- (instancetype)initWithModel:(LOTComposition *)model inBundle:(NSBundle *)bundle {
  self = [super initWithFrame:model.compBounds];
  if (self) {
    _bundle = bundle;
    [self _commonInit];
    [self _initializeAnimationContainer];
    [self _setupWithSceneModel:model];
  }
  return self;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self _commonInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    [self _commonInit];
  }
  return self;
}

# pragma mark - Internal Methods

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR

- (void)_initializeAnimationContainer {
  self.clipsToBounds = YES;
}

#else

- (void)_initializeAnimationContainer {
  self.wantsLayer = YES;
}

#endif

- (void)_commonInit {
  _animationSpeed = 1;
  _animationProgress = 0;
  _loopAnimation = NO;
  _autoReverseAnimation = NO;
  _playRangeEndFrame = nil;
  _playRangeStartFrame = nil;
  _playRangeEndProgress = 0;
  _playRangeStartProgress = 0;
}

- (void)_setupWithSceneModel:(LOTComposition *)model {
  if (_sceneModel) {
    [self _removeCurrentAnimationIfNecessary];
    [self _callCompletionIfNecessary:NO];
    [_compContainer removeFromSuperlayer];
    _compContainer = nil;
    _sceneModel = nil;
    [self _commonInit];
  }
  
  _sceneModel = model;
  _compContainer = [[LOTCompositionContainer alloc] initWithModel:nil inLayerGroup:nil withLayerGroup:_sceneModel.layerGroup withAssestGroup:_sceneModel.assetGroup];
  [self.layer addSublayer:_compContainer];
  if (ENABLE_DEBUG_LOGGING) {
    [self logHierarchyKeypaths];
  }
  [self _restoreState];
  [self setNeedsLayout];
}

- (void)_restoreState {
  if (_isAnimationPlaying) {
    _isAnimationPlaying = NO;
    if (_playRangeStartFrame && _playRangeEndProgress) {
      [self playFromFrame:_playRangeStartFrame toFrame:_playRangeEndFrame withCompletion:self.completionBlock];
    } else if (_playRangeEndProgress != _playRangeStartProgress) {
      [self playFromProgress:_playRangeStartProgress toProgress:_playRangeEndProgress withCompletion:self.completionBlock];
    } else {
      [self playWithCompletion:self.completionBlock];
    }
  } else {
    self.animationProgress = _animationProgress;
  }
}

- (void)_removeCurrentAnimationIfNecessary {
  _isAnimationPlaying = NO;
  [_compContainer removeAllAnimations];
}

- (CGFloat)_progressForFrame:(NSNumber *)frame {
  if (!_sceneModel) {
    return 0;
  }
  return ((frame.floatValue - _sceneModel.startFrame.floatValue) / (_sceneModel.endFrame.floatValue - _sceneModel.startFrame.floatValue));
}

- (NSNumber *)_frameForProgress:(CGFloat)progress {
  if (!_sceneModel) {
    return @0;
  }
  return @(((_sceneModel.endFrame.floatValue - _sceneModel.startFrame.floatValue) * progress) + _sceneModel.startFrame.floatValue);
}

- (BOOL)_isSpeedNegative {
  // If the animation speed is negative, then we're moving backwards.
  return _animationSpeed >= 0;
}

# pragma mark - Completion Block

- (void)_callCompletionIfNecessary:(BOOL)complete {
  if (self.completionBlock) {
    LOTAnimationCompletionBlock completion = self.completionBlock;
    self.completionBlock = nil;
    completion(complete);
  }
}

# pragma mark - External Methods - Model

- (void)setSceneModel:(LOTComposition *)sceneModel {
  [self _setupWithSceneModel:sceneModel];
}

# pragma mark - External Methods - Play Control

- (void)play {
  if (!_sceneModel) {
    _isAnimationPlaying = YES;
    return;
  }
  [self playFromFrame:_sceneModel.startFrame toFrame:_sceneModel.endFrame withCompletion:nil];
}

- (void)playWithCompletion:(LOTAnimationCompletionBlock)completion {
  if (!_sceneModel) {
    _isAnimationPlaying = YES;
    self.completionBlock = completion;
    return;
  }
  [self playFromFrame:_sceneModel.startFrame toFrame:_sceneModel.endFrame withCompletion:completion];
}

- (void)playToProgress:(CGFloat)progress withCompletion:(nullable LOTAnimationCompletionBlock)completion {
  [self playFromProgress:0 toProgress:progress withCompletion:completion];
}

- (void)playFromProgress:(CGFloat)fromStartProgress
              toProgress:(CGFloat)toEndProgress
          withCompletion:(nullable LOTAnimationCompletionBlock)completion {
  if (!_sceneModel) {
    _isAnimationPlaying = YES;
    self.completionBlock = completion;
    _playRangeStartProgress = fromStartProgress;
    _playRangeEndProgress = toEndProgress;
    return;
  }
  [self playFromFrame:[self _frameForProgress:fromStartProgress]
              toFrame:[self _frameForProgress:toEndProgress]
       withCompletion:completion];
}

- (void)playToFrame:(nonnull NSNumber *)toFrame
     withCompletion:(nullable LOTAnimationCompletionBlock)completion {
  [self playFromFrame:_sceneModel.startFrame toFrame:toFrame withCompletion:completion];
}

- (void)playFromFrame:(nonnull NSNumber *)fromStartFrame
              toFrame:(nonnull NSNumber *)toEndFrame
       withCompletion:(nullable LOTAnimationCompletionBlock)completion {
  if (_isAnimationPlaying) {
    return;
  }
  _playRangeStartFrame = fromStartFrame;
  _playRangeEndFrame = toEndFrame;
  if (completion) {
    self.completionBlock = completion;
  }
  if (!_sceneModel) {
    _isAnimationPlaying = YES;
    return;
  }
  if (!self.window) {
    _shouldRestoreStateWhenAttachedToWindow = YES;
    _completionBlockToRestoreWhenAttachedToWindow = self.completionBlock;
    self.completionBlock = nil;
  }

  BOOL playingForward = ((_animationSpeed > 0) && (toEndFrame.floatValue > fromStartFrame.floatValue))
    || ((_animationSpeed < 0) && (fromStartFrame.floatValue > toEndFrame.floatValue));

  CGFloat leftFrameValue = MIN(fromStartFrame.floatValue, toEndFrame.floatValue);
  CGFloat rightFrameValue = MAX(fromStartFrame.floatValue, toEndFrame.floatValue);

  NSNumber *currentFrame = [self _frameForProgress:_animationProgress];

  currentFrame = @(MAX(MIN(currentFrame.floatValue, rightFrameValue), leftFrameValue));

  if (currentFrame.floatValue == rightFrameValue && playingForward) {
    currentFrame = @(leftFrameValue);
  } else if (currentFrame.floatValue == leftFrameValue && !playingForward) {
    currentFrame = @(rightFrameValue);
  }
  _animationProgress = [self _progressForFrame:currentFrame];
  
  CGFloat currentProgress = _animationProgress * (_sceneModel.endFrame.floatValue - _sceneModel.startFrame.floatValue);
  CGFloat skipProgress;
  if (playingForward) {
    skipProgress = currentProgress - leftFrameValue;
  } else {
    skipProgress = rightFrameValue - currentProgress;
  }
  NSTimeInterval offset = MAX(0, skipProgress) / _sceneModel.framerate.floatValue;

  NSTimeInterval duration = (ABS(toEndFrame.floatValue - fromStartFrame.floatValue) / _sceneModel.framerate.floatValue);
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"currentFrame"];
  animation.speed = _animationSpeed;
  animation.fromValue = fromStartFrame;
  animation.toValue = toEndFrame;
  animation.duration = duration;
  animation.fillMode = kCAFillModeBoth;
  animation.repeatCount = _loopAnimation ? HUGE_VALF : 1;
  animation.autoreverses = _autoReverseAnimation;
  animation.delegate = self;
  animation.removedOnCompletion = NO;
  if (offset != 0) {
    animation.beginTime = CACurrentMediaTime() - (offset * 1 / _animationSpeed);
  }
  [_compContainer addAnimation:animation forKey:kCompContainerAnimationKey];
  _isAnimationPlaying = YES;
}

#pragma mark - Other Time Controls

- (void)stop {
  _isAnimationPlaying = NO;
  if (_sceneModel) {
    [self setProgressWithFrame:_sceneModel.startFrame callCompletionIfNecessary:YES];
  }
}

- (void)pause {
  if (!_sceneModel ||
      !_isAnimationPlaying) {
    _isAnimationPlaying = NO;
    return;
  }
  NSNumber *frame = [_compContainer.presentationLayer.currentFrame copy];
  [self setProgressWithFrame:frame callCompletionIfNecessary:YES];
}

- (void)setAnimationProgress:(CGFloat)animationProgress {
  if (!_sceneModel) {
    _animationProgress = animationProgress;
    return;
  }
  [self setProgressWithFrame:[self _frameForProgress:animationProgress] callCompletionIfNecessary:YES];
}

- (void)setProgressWithFrame:(nonnull NSNumber *)currentFrame {
  [self setProgressWithFrame:currentFrame callCompletionIfNecessary:YES];
}

- (void)setProgressWithFrame:(nonnull NSNumber *)currentFrame callCompletionIfNecessary:(BOOL)callCompletion {
  [self _removeCurrentAnimationIfNecessary];

  if (_shouldRestoreStateWhenAttachedToWindow) {
    _shouldRestoreStateWhenAttachedToWindow = NO;

    self.completionBlock = _completionBlockToRestoreWhenAttachedToWindow;
    _completionBlockToRestoreWhenAttachedToWindow = nil;
  }

  _animationProgress = [self _progressForFrame:currentFrame];

  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  _compContainer.currentFrame = currentFrame;
  [_compContainer setNeedsDisplay];
  [CATransaction commit];
  if (callCompletion) {
    [self _callCompletionIfNecessary:NO];
  }
}

- (void)setLoopAnimation:(BOOL)loopAnimation {
  _loopAnimation = loopAnimation;
  if (_isAnimationPlaying && _sceneModel) {
    NSNumber *frame = [_compContainer.presentationLayer.currentFrame copy];
    [self setProgressWithFrame:frame callCompletionIfNecessary:NO];
    [self playFromFrame:_playRangeStartFrame toFrame:_playRangeEndFrame withCompletion:self.completionBlock];
  }
}

- (void)setAnimationSpeed:(CGFloat)animationSpeed {
  _animationSpeed = animationSpeed;
  if (_isAnimationPlaying && _sceneModel) {
    NSNumber *frame = [_compContainer.presentationLayer.currentFrame copy];
    [self setProgressWithFrame:frame callCompletionIfNecessary:NO];
    [self playFromFrame:_playRangeStartFrame toFrame:_playRangeEndFrame withCompletion:self.completionBlock];
  }
}

# pragma mark - External Methods - Cache

- (void)setCacheEnable:(BOOL)cacheEnable {
  _cacheEnable = cacheEnable;
  if (!self.sceneModel.cacheKey) {
    return;
  }
  if (cacheEnable) {
    [[LOTAnimationCache sharedCache] addAnimation:_sceneModel forKey:self.sceneModel.cacheKey];
  } else {
    [[LOTAnimationCache sharedCache] removeAnimationForKey:self.sceneModel.cacheKey];
  }
}

# pragma mark - External Methods - Other

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR

- (void)addSubview:(nonnull LOTView *)view
      toLayerNamed:(nonnull NSString *)layer
    applyTransform:(BOOL)applyTransform {
  [self _layout];
  CGRect viewRect = view.frame;
  LOTView *wrapperView = [[LOTView alloc] initWithFrame:viewRect];
  view.frame = view.bounds;
  view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [wrapperView addSubview:view];
  [self addSubview:wrapperView];
  [_compContainer addSublayer:wrapperView.layer toLayerNamed:layer applyTransform:applyTransform];
}

#else

- (void)addSubview:(nonnull LOTView *)view
      toLayerNamed:(nonnull NSString *)layer
    applyTransform:(BOOL)applyTransform {
  CGRect viewRect = view.frame;
  LOTView *wrapperView = [[LOTView alloc] initWithFrame:viewRect];
  view.frame = view.bounds;
  view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  [wrapperView addSubview:view];
  [self addSubview:wrapperView];
  [_compContainer addSublayer:wrapperView.layer toLayerNamed:layer applyTransform:applyTransform];
}

#endif

- (CGRect)convertRect:(CGRect)rect
         toLayerNamed:(NSString *_Nullable)layerName {
  [self _layout];
  if (layerName == nil) {
    return [self.layer convertRect:rect toLayer:_compContainer];
  }
  return [_compContainer convertRect:rect fromLayer:self.layer toLayerNamed:layerName];
}

- (void)setValue:(nonnull id)value
      forKeypath:(nonnull NSString *)keypath
         atFrame:(nullable NSNumber *)frame{
  BOOL didUpdate = [_compContainer setValue:value forKeypath:keypath atFrame:frame];
  if (didUpdate) {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_compContainer displayWithFrame:_compContainer.currentFrame forceUpdate:YES];
    [CATransaction commit];
  } else {
    NSLog(@"%s: Keypath Not Found: %@", __PRETTY_FUNCTION__, keypath);
  }
}

- (void)logHierarchyKeypaths {
  [_compContainer logHierarchyKeypathsWithParent:nil];
}

# pragma mark - Semi-Private Methods

- (CALayer * _Nullable)layerForKey:(NSString * _Nonnull)keyname {
  return _compContainer.childMap[keyname];
}

- (NSArray * _Nonnull)compositionLayers {
  return _compContainer.childLayers;
}

# pragma mark - Getters and Setters

- (CGFloat)animationDuration {
  if (!_sceneModel) {
    return 0;
  }
  CAAnimation *play = [_compContainer animationForKey:kCompContainerAnimationKey];
  if (play) {
    return play.duration;
  }
  return (_sceneModel.endFrame.floatValue - _sceneModel.startFrame.floatValue) / _sceneModel.framerate.floatValue;
}

- (CGFloat)animationProgress {
  if (_isAnimationPlaying &&
      _compContainer.presentationLayer) {
    CGFloat activeProgress = [self _progressForFrame:[(LOTCompositionContainer *)_compContainer.presentationLayer currentFrame]];
    return activeProgress;
  }
  return _animationProgress;
}

# pragma mark - Overrides

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR

#define LOTViewContentMode UIViewContentMode
#define LOTViewContentModeScaleToFill UIViewContentModeScaleToFill
#define LOTViewContentModeScaleAspectFit UIViewContentModeScaleAspectFit
#define LOTViewContentModeScaleAspectFill UIViewContentModeScaleAspectFill
#define LOTViewContentModeRedraw UIViewContentModeRedraw
#define LOTViewContentModeCenter UIViewContentModeCenter
#define LOTViewContentModeTop UIViewContentModeTop
#define LOTViewContentModeBottom UIViewContentModeBottom
#define LOTViewContentModeLeft UIViewContentModeLeft
#define LOTViewContentModeRight UIViewContentModeRight
#define LOTViewContentModeTopLeft UIViewContentModeTopLeft
#define LOTViewContentModeTopRight UIViewContentModeTopRight
#define LOTViewContentModeBottomLeft UIViewContentModeBottomLeft
#define LOTViewContentModeBottomRight UIViewContentModeBottomRight

- (CGSize)intrinsicContentSize {
  if (!_sceneModel) {
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
  }
  return _sceneModel.compBounds.size;
}

- (void)didMoveToSuperview {
  [super didMoveToSuperview];
  if (self.superview == nil) {
    [self _callCompletionIfNecessary:NO];
  }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
  // When this view or its superview is leaving the screen, e.g. a modal is presented or another
  // screen is pushed, this method will get called with newWindow value set to nil - indicating that
  // this view will be detached from the visible window.
  // When a view is detached, animations will stop - but will not automatically resumed when it's
  // re-attached back to window, e.g. when the presented modal is dismissed or another screen is
  // pop.
  if (newWindow) {
    // The view is being re-attached, resume animation if needed.
    if (_shouldRestoreStateWhenAttachedToWindow) {
      _shouldRestoreStateWhenAttachedToWindow = NO;

      _isAnimationPlaying = YES;
      _completionBlock = _completionBlockToRestoreWhenAttachedToWindow;
      _completionBlockToRestoreWhenAttachedToWindow = nil;

      [self performSelector:@selector(_restoreState) withObject:nil afterDelay:0];
    }
  } else {
    // The view is being detached, capture information that need to be restored later.
    if (_isAnimationPlaying) {
        [self pause];
      _shouldRestoreStateWhenAttachedToWindow = YES;
      _completionBlockToRestoreWhenAttachedToWindow = _completionBlock;
      _completionBlock = nil;
    }
  }
}

- (void)setContentMode:(LOTViewContentMode)contentMode {
  [super setContentMode:contentMode];
  [self setNeedsLayout];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self _layout];
}

#else
    
- (void)setCompletionBlock:(LOTAnimationCompletionBlock)completionBlock {
    if (completionBlock) {
      _completionBlock = ^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(finished); });
      };
    }
    else {
      _completionBlock = nil;
    }
}

- (void)setContentMode:(LOTViewContentMode)contentMode {
  _contentMode = contentMode;
  [self setNeedsLayout];
}

- (void)setNeedsLayout {
  self.needsLayout = YES;
}

- (BOOL)isFlipped {
  return YES;
}

- (BOOL)wantsUpdateLayer {
  return YES;
}

- (void)layout {
  [super layout];
  [self _layout];
}

#endif

- (void)_layout {
  CGPoint centerPoint = LOT_RectGetCenterPoint(self.bounds);
  CATransform3D xform;

  if (self.contentMode == LOTViewContentModeScaleToFill) {
    CGSize scaleSize = CGSizeMake(self.bounds.size.width / self.sceneModel.compBounds.size.width,
            self.bounds.size.height / self.sceneModel.compBounds.size.height);
    xform = CATransform3DMakeScale(scaleSize.width, scaleSize.height, 1);
  } else if (self.contentMode == LOTViewContentModeScaleAspectFit) {
    CGFloat compAspect = self.sceneModel.compBounds.size.width / self.sceneModel.compBounds.size.height;
    CGFloat viewAspect = self.bounds.size.width / self.bounds.size.height;
    BOOL scaleWidth = compAspect > viewAspect;
    CGFloat dominantDimension = scaleWidth ? self.bounds.size.width : self.bounds.size.height;
    CGFloat compDimension = scaleWidth ? self.sceneModel.compBounds.size.width : self.sceneModel.compBounds.size.height;
    CGFloat scale = dominantDimension / compDimension;
    xform = CATransform3DMakeScale(scale, scale, 1);
  } else if (self.contentMode == LOTViewContentModeScaleAspectFill) {
    CGFloat compAspect = self.sceneModel.compBounds.size.width / self.sceneModel.compBounds.size.height;
    CGFloat viewAspect = self.bounds.size.width / self.bounds.size.height;
    BOOL scaleWidth = compAspect < viewAspect;
    CGFloat dominantDimension = scaleWidth ? self.bounds.size.width : self.bounds.size.height;
    CGFloat compDimension = scaleWidth ? self.sceneModel.compBounds.size.width : self.sceneModel.compBounds.size.height;
    CGFloat scale = dominantDimension / compDimension;
    xform = CATransform3DMakeScale(scale, scale, 1);
  } else {
    xform = CATransform3DIdentity;
  }

  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  _compContainer.transform = CATransform3DIdentity;
  _compContainer.bounds = _sceneModel.compBounds;
  _compContainer.viewportBounds = _sceneModel.compBounds;
  _compContainer.transform = xform;
  _compContainer.position = centerPoint;
  [CATransaction commit];
}

# pragma mark - CAANimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)complete {
  if ([_compContainer animationForKey:kCompContainerAnimationKey] == anim &&
      [anim isKindOfClass:[CABasicAnimation class]]) {
    CABasicAnimation *playAnimation = (CABasicAnimation *)anim;
    NSNumber *frame = _compContainer.presentationLayer.currentFrame;
    if (complete) {
      // Set the final frame based on the animation to/from values. If playing forward, use the
      // toValue otherwise we want to end on the fromValue.
      frame = [self _isSpeedNegative] ? (NSNumber *)playAnimation.toValue : (NSNumber *)playAnimation.fromValue;
    }
    [self _removeCurrentAnimationIfNecessary];
    [self setProgressWithFrame:frame callCompletionIfNecessary:NO];
    [self _callCompletionIfNecessary:complete];
  }
}

@end
