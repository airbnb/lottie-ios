//
//  LOTAnimationView
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTAnimationView.h"
#import "LOTPlatformCompat.h"
#import "LOTLayerView.h"
#import "LOTModels.h"
#import "LOTHelpers.h"
#import "LOTAnimationView_Internal.h"
#import "LOTAnimationCache.h"

const NSTimeInterval singleFrameTimeValue = 1.0 / 60.0;

@implementation LOTAnimationState {
  BOOL _needsAnimationUpdate;
  BOOL _animationIsPlaying;
  BOOL _playFromBeginning;
  CFTimeInterval _previousLocalTime;
  CGFloat _animatedProgress;
}

- (id)initWithDuration:(CGFloat)duration layer:(CALayer *)layer{
  self = [super init];
  if (self) {
    _layer = layer;
    _needsAnimationUpdate = NO;
    _animationIsPlaying = NO;
    _loopAnimation = NO;
    
    _animationDuration = duration;
    _animatedProgress = 0;
    _animationSpeed = 1;
    
    // Initial Setup of Layer
    _layer.fillMode = kCAFillModeBoth;
    _layer.duration = _animationDuration;
    _layer.speed = 0;
    _layer.timeOffset = 0;
    _layer.beginTime = CACurrentMediaTime();

    _previousLocalTime = -1.f;
    [self setNeedsAnimationUpdate];
  }
  return self;
}

#pragma mark -- External Methods

- (void)updateAnimationLayerClockTime:(CFTimeInterval)clockTime timeOffset:(CFTimeInterval)timeOffset {
  if (_needsAnimationUpdate) {
    return;
  }
  CGFloat speed = _animationIsPlaying ? _animationSpeed : 0;
  
  _layer.speed = speed;
  _layer.repeatCount = _loopAnimation ? HUGE_VALF : 0;
  _layer.timeOffset = 0;
  _layer.beginTime = 0;
  
  if (speed == 0) {
    _layer.timeOffset = timeOffset;
  } else {
    CFTimeInterval offsetTime =  ((timeOffset != 0) ?
                                  timeOffset / speed :
                                  timeOffset);
    _layer.beginTime = CACurrentMediaTime() - offsetTime;
  }
}

- (void)setNeedsAnimationUpdate {
  if (!_needsAnimationUpdate) {
    _needsAnimationUpdate = YES;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      _needsAnimationUpdate = NO;
      if (_animationIsPlaying) {
        [self setAnimationIsPlaying:_animationIsPlaying];
      } else {
        [self setAnimatedProgress:_animatedProgress];
      }
    }];
  }
}

#pragma mark -- Setters

- (void)setAnimationDoesLoop:(BOOL)loopAnimation {
  _loopAnimation = loopAnimation;
  CFTimeInterval offset = [_layer convertTime:CACurrentMediaTime() fromLayer:nil];
  CFTimeInterval clock = CACurrentMediaTime();
  [self updateAnimationLayerClockTime:clock timeOffset:offset];
}

- (void)setAnimationIsPlaying:(BOOL)animationIsPlaying  {
  _animationIsPlaying = animationIsPlaying;
  CFTimeInterval offset = [_layer convertTime:CACurrentMediaTime() fromLayer:nil];
  CFTimeInterval clock = CACurrentMediaTime();

  if (_animationIsPlaying) {
    if (_playFromBeginning) {
      _playFromBeginning = NO;
      offset = 0;
    }
  } else {
    _animatedProgress =  offset / _animationDuration;
  }
  [self updateAnimationLayerClockTime:clock timeOffset:offset];
}

- (void)setAnimatedProgress:(CGFloat)animatedProgress {
  if (_playFromBeginning) {
    _playFromBeginning = NO;
  }
  _animatedProgress = animatedProgress > 1 ? fmod(animatedProgress, 1) : MAX(animatedProgress, 0);
  _animationIsPlaying = NO;
  CFTimeInterval offset = _animatedProgress == 1 ? _animationDuration - singleFrameTimeValue : _animatedProgress * _animationDuration;
  CFTimeInterval clock = CACurrentMediaTime();
  [self updateAnimationLayerClockTime:clock timeOffset:offset];
}

- (void)setAnimationSpeed:(CGFloat)speed {
  _animationSpeed = speed;
  CFTimeInterval offset = [_layer convertTime:CACurrentMediaTime() fromLayer:nil];
  CFTimeInterval clock = CACurrentMediaTime();
  [self updateAnimationLayerClockTime:clock timeOffset:offset];
}

#pragma mark -- Getters

- (CGFloat)animatedProgress {
  if (_animationIsPlaying) {
    CFTimeInterval localTime = [_layer convertTime:CACurrentMediaTime() fromLayer:nil];
    NSInteger eLocalTime = roundf(localTime * 10000);
    NSInteger eDuration = roundf(_animationDuration * 10000);
    if (eLocalTime > 0) {
      return  (float)eLocalTime / (float)eDuration;
    }
  }
  return _animatedProgress;
}

- (BOOL)animationIsPlaying {
  if (_animationIsPlaying && !_loopAnimation && _layer) {
    CFTimeInterval localTime = [_layer convertTime:CACurrentMediaTime() fromLayer:nil];
    if (_previousLocalTime == localTime && localTime != 0) {
      _animationIsPlaying = NO;
      NSInteger eLocalTime = roundf(localTime * 10000);
      NSInteger eDuration = roundf(_animationDuration * 10000);

      _animatedProgress = (float)eLocalTime / (float)eDuration;
      if (eLocalTime == eDuration) {
        _playFromBeginning = YES;
      }
    }
    _previousLocalTime = localTime;
  }
  return _animationIsPlaying;
}

- (void)logStats:(NSString *)logName {
  CFTimeInterval localTime = [_layer convertTime:CACurrentMediaTime() fromLayer:nil];
  NSLog(@"LOTAnimationState %@ || Is Playing %@ || Duration %f || Speed %lf ||  Progress %lf || Local Time %lf || ",
        logName, (_animationIsPlaying ? @"YES" : @"NO"), self.animationDuration, _layer.speed, self.animatedProgress, localTime);
}

@end

@interface LOTCustomChild : NSObject

@property (nonatomic, strong) LOTView *childView;
@property (nonatomic, weak) LOTLayerView *layer;
@property (nonatomic, assign) LOTConstraintType constraint;

@end

@implementation LOTCustomChild

@end

@implementation LOTAnimationView {
  NSDictionary *_layerMap;
  NSDictionary *_layerNameMap;
  NSMutableArray *_customLayers;
  CALayer *_animationContainer;
  CADisplayLink *_completionDisplayLink;
  BOOL hasFullyInitialized_;
}

# pragma mark - Initializers

+ (instancetype)animationNamed:(NSString *)animationName {
  NSArray *components = [animationName componentsSeparatedByString:@"."];
  animationName = components.firstObject;
  
  LOTComposition *comp = [[LOTAnimationCache sharedCache] animationForKey:animationName];
  if (comp) {
    return [[LOTAnimationView alloc] initWithModel:comp];
  }
  
  NSError *error;
  NSString *filePath = [[NSBundle mainBundle] pathForResource:animationName ofType:@"json"];
  NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
  NSDictionary  *JSONObject = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
                                                                         options:0 error:&error] : nil;
  if (JSONObject && !error) {
    LOTComposition *laScene = [[LOTComposition alloc] initWithJSON:JSONObject];
    [[LOTAnimationCache sharedCache] addAnimation:laScene forKey:animationName];
    return [[LOTAnimationView alloc] initWithModel:laScene];
  }
  
  NSException* resourceNotFoundException = [NSException exceptionWithName:@"ResourceNotFoundException"
                                                                   reason:[error localizedDescription]
                                                                 userInfo:nil];
  @throw resourceNotFoundException;
}

+ (instancetype)animationFromJSON:(NSDictionary *)animationJSON {
  LOTComposition *laScene = [[LOTComposition alloc] initWithJSON:animationJSON];
  return [[LOTAnimationView alloc] initWithModel:laScene];
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
  self = [super initWithFrame:CGRectZero];
  if (self) {
    LOTComposition *laScene = [[LOTAnimationCache sharedCache] animationForKey:url.absoluteString];
    if (laScene) {
      [self _initializeAnimationContainer];
      [self _setupWithSceneModel:laScene restoreAnimationState:NO];
    } else {
      _animationState = [[LOTAnimationState alloc] initWithDuration:singleFrameTimeValue layer:nil];
      dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
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
        
        LOTComposition *laScene = [[LOTComposition alloc] initWithJSON:animationJSON];
        dispatch_async(dispatch_get_main_queue(), ^(void){
          [[LOTAnimationCache sharedCache] addAnimation:laScene forKey:url.absoluteString];
          [self _initializeAnimationContainer];
          [self _setupWithSceneModel:laScene restoreAnimationState:YES];
        });
      });
    }
  }
  return self;
}

- (instancetype)initWithModel:(LOTComposition *)model {
  self = [super initWithFrame:model.compBounds];
  if (self) {
    [self _initializeAnimationContainer];
    [self _setupWithSceneModel:model restoreAnimationState:NO];
  }
  return self;
}

# pragma mark - Internal Methods

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

- (void)_initializeAnimationContainer {
    _animationContainer = [CALayer new];
    _animationContainer.masksToBounds = YES;
    [self.layer addSublayer:_animationContainer];
    self.clipsToBounds = YES;
}

#else

- (void)_initializeAnimationContainer {
    self.wantsLayer = YES;
    _animationContainer = [CALayer new];
    _animationContainer.masksToBounds = YES;
    [self.layer addSublayer:_animationContainer];
}

#endif

- (void)_setupWithSceneModel:(LOTComposition *)model restoreAnimationState:(BOOL)restoreAnimation {
  _sceneModel = model;
  [self _buildSubviewsFromModel];
  LOTAnimationState *oldState = _animationState;
  _animationState = [[LOTAnimationState alloc] initWithDuration:_sceneModel.timeDuration layer:_animationContainer];

  if (restoreAnimation && oldState) {
    [self setLoopAnimation:oldState.loopAnimation];
    [self setAnimationSpeed:oldState.animationSpeed];
    [self setAnimationProgress:oldState.animatedProgress];
    if (oldState.animationIsPlaying) {
      [self play];
    }
  }
  
  if (_sceneModel) {
    hasFullyInitialized_ = YES;
  }
}

- (void)_buildSubviewsFromModel {
  if (_customLayers) {
    for (LOTCustomChild *child in _customLayers) {
      [child.childView.layer removeFromSuperlayer];
    }
    _customLayers = nil;
  }
  
  if (_layerMap) {
    _layerMap = nil;
    [_animationContainer removeAllAnimations];
    [_animationContainer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
  }
  
  if (_layerNameMap) {
    _layerNameMap = nil;
  }
  
  _animationContainer.transform = CATransform3DIdentity;
  _animationContainer.bounds = _sceneModel.compBounds;
  
  NSMutableDictionary *layerMap = [NSMutableDictionary dictionary];
  NSMutableDictionary *layerNameMap = [NSMutableDictionary dictionary];
  
  NSArray *reversedItems = [[_sceneModel.layers reverseObjectEnumerator] allObjects];
  
  LOTLayerView *maskedLayer = nil;
  for (LOTLayer *layer in reversedItems) {
    LOTLayerView *layerView = [[LOTLayerView alloc] initWithModel:layer inComposition:_sceneModel];
    layerMap[layer.layerID] = layerView;
    layerNameMap[layer.layerName] = layerView;
    if (maskedLayer) {
      maskedLayer.mask = layerView;
      maskedLayer = nil;
    } else {
      if (layer.matteType == LOTMatteTypeAdd) {
        maskedLayer = layerView;
      }
      [_animationContainer addSublayer:layerView];
    }
  }
  _layerMap = layerMap;
  _layerNameMap = layerNameMap;
}

- (void)_layoutCustomChildLayers {
  if (!_customLayers.count) {
    return;
  }
  
  for (LOTCustomChild *child in _customLayers) {
    switch (child.constraint) {
      case LOTConstraintTypeAlignToLayer:
        child.childView.frame = child.layer.bounds;
        break;
      case LOTConstraintTypeAlignToBounds: {
        CGRect selfBounds = _animationContainer.frame;
        CGRect convertedBounds = [child.childView.layer.superlayer convertRect:selfBounds fromLayer:self.layer];
        child.childView.layer.frame = convertedBounds;
      } break;
      default:
        break;
    }
  }
}

# pragma mark - External Methods

- (void)play {
  [self playWithCompletion:nil];
}

- (void)playWithCompletion:(LOTAnimationCompletionBlock)completion {
  if (completion) {
    self.completionBlock = completion;
  }

  if (!hasFullyInitialized_) {
    [_animationState setAnimationIsPlaying:YES];
    return;
  }
  
  if (_animationState.animationIsPlaying == NO) {
    [_animationState setAnimationIsPlaying:YES];
    [self startDisplayLink];
  }
}

- (void)pause {
  if (!hasFullyInitialized_) {
    [_animationState setAnimationIsPlaying:NO];
    return;
  }
  
  if (_animationState.animationIsPlaying) {
    [_animationState setAnimationIsPlaying:NO];
    [self stopDisplayLink];
    
    [self _callCompletionIfNecesarry];
  }
}

- (void)addSubview:(LOTView *)view
      toLayerNamed:(NSString *)layer {
  LOTConstraintType constraint = LOTConstraintTypeAlignToBounds;
  LOTLayerView *layerObject = _layerNameMap[layer];
  LOTCustomChild *newChild = [[LOTCustomChild alloc] init];
  newChild.constraint = constraint;
  newChild.childView = view;
  
  if (!layer) {
    NSException* layerNotFoundExpection = [NSException exceptionWithName:@"LayerNotFoundException"
                                                                  reason:@"The required layer was not specified."
                                                                userInfo:nil];
    @throw layerNotFoundExpection;
  } else {
    newChild.layer = layerObject;
    [layerObject.superlayer insertSublayer:view.layer above:layerObject];
    
    view.layer.mask = layerObject;
  }
  
  if (!_customLayers) {
    _customLayers = [NSMutableArray array];
  }
  [_customLayers addObject:newChild];
  [self _layoutCustomChildLayers];
}

# pragma mark - Display Link

- (void)startDisplayLink {
  if (_animationState.animationIsPlaying == NO ||
      _animationState.loopAnimation) {
    return;
  }
  
  [self stopDisplayLink];
  
  _completionDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(checkAnimationState)];
  [_completionDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopDisplayLink {
  [_completionDisplayLink invalidate];
  _completionDisplayLink = nil;
}

- (void)checkAnimationState {
  if (self.animationState.animationIsPlaying == NO) {
    [self stopDisplayLink];
    [self _callCompletionIfNecesarry];
  }
}

- (void)_callCompletionIfNecesarry {
  if (self.completionBlock && hasFullyInitialized_) {
    self.completionBlock(_animationState.animatedProgress == 1);
    self.completionBlock = nil;
  }
}

# pragma mark - Getters and Setters

- (void)setAnimationProgress:(CGFloat)animationProgress {
  if (_animationState.animationIsPlaying) {
    [self _callCompletionIfNecesarry];
  }
  
  [_animationState setAnimatedProgress:animationProgress];
  
  [self stopDisplayLink];
}

- (CGFloat)animationProgress {
  return _animationState.animatedProgress;
}

- (void)setLoopAnimation:(BOOL)loopAnimation {
  [_animationState setAnimationDoesLoop:loopAnimation];
  if (loopAnimation) {
    [self stopDisplayLink];
  }
}

- (BOOL)loopAnimation {
  return _animationState.loopAnimation;
}

-(void)setAnimationSpeed:(CGFloat)animationSpeed {
  [_animationState setAnimationSpeed:animationSpeed];
}

- (CGFloat)animationSpeed {
  return _animationState.animationSpeed;
}

- (BOOL)isAnimationPlaying {
  return _animationState.animationIsPlaying;
}

- (CGFloat)animationDuration {
  return _animationState.animationDuration;
}

# pragma mark - Overrides

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

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

- (void)didMoveToWindow {
  [super didMoveToWindow];
  [_animationState setNeedsAnimationUpdate];
}

- (void)didMoveToSuperview {
  [super didMoveToSuperview];
  [_animationState setNeedsAnimationUpdate];
}

- (void)removeFromSuperview {
  [self pause];
  [super removeFromSuperview];
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

- (CGSize)intrinsicContentSize {
    return _sceneModel.compBounds.size;
}

- (void)_layout {
  if (!hasFullyInitialized_) {
    _animationContainer.bounds = self.bounds;
    return;
  }

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
  _animationContainer.transform = CATransform3DIdentity;
  _animationContainer.bounds = _sceneModel.compBounds;
  _animationContainer.transform = xform;
  _animationContainer.position = centerPoint;
  [CATransaction commit];
  [self _layoutCustomChildLayers];
}

@end
