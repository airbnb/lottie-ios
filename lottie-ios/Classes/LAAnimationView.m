//
//  LAAnimationView
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAAnimationView.h"
#import "LALayerView.h"
#import "LAModels.h"
#import "LAHelpers.h"
#import "LAAnimationView_Internal.h"
#import "LAAnimationCache.h"

const NSTimeInterval singleFrameTimeValue = 1.0 / 60.0;

@implementation LAAnimationState {
  BOOL _animationIsPlaying;
  BOOL _playFromBeginning;
  CFTimeInterval _previousLocalTime;
  CGFloat _animatedProgress;
}

- (id)initWithDuration:(CGFloat)duration layer:(CALayer *)layer{
  self = [super init];
  if (self) {
    _layer = layer;
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

  }
  return self;
}

#pragma mark -- External Methods

- (void)updateAnimationLayerClockTime:(CFTimeInterval)clockTime timeOffset:(CFTimeInterval)timeOffset {
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

#pragma mark -- Setters

- (void)setAnimationDoesLoop:(BOOL)loopAnimation {
  _loopAnimation = loopAnimation;
  CFTimeInterval offset = [_layer convertTime:CACurrentMediaTime() fromLayer:nil];
  CFTimeInterval clock = CACurrentMediaTime();
  [self updateAnimationLayerClockTime:clock timeOffset:offset];
}

- (void)setAnimationIsPlaying:(BOOL)animationIsPlaying  {
  if (_animationIsPlaying == animationIsPlaying) {
    return;
  }
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
  NSLog(@"LAAnimationState %@ || Is Playing %@ || Duration %f || Speed %lf ||  Progress %lf || Local Time %lf || ",
        logName, (_animationIsPlaying ? @"YES" : @"NO"), self.animationDuration, _layer.speed, self.animatedProgress, localTime);
}

@end

@interface LACustomChild : NSObject

@property (nonatomic, strong) UIView *childView;
@property (nonatomic, weak) LALayerView *layer;
@property (nonatomic, assign) LAConstraintType constraint;

@end

@implementation LACustomChild

@end

@implementation LAAnimationView {
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
  
  LAComposition *comp = [[LAAnimationCache sharedCache] animationForKey:animationName];
  if (comp) {
    return [[LAAnimationView alloc] initWithModel:comp];
  }
  
  NSError *error;
  NSString *filePath = [[NSBundle mainBundle] pathForResource:animationName ofType:@"json"];
  NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
  NSDictionary  *JSONObject = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
                                                                         options:0 error:&error] : nil;
  if (JSONObject && !error) {
    LAComposition *laScene = [[LAComposition alloc] initWithJSON:JSONObject];
    [[LAAnimationCache sharedCache] addAnimation:laScene forKey:animationName];
    return [[LAAnimationView alloc] initWithModel:laScene];
  }
  
  return [[LAAnimationView alloc] initWithModel:nil];
}

+ (instancetype)animationFromJSON:(NSDictionary *)animationJSON {
  LAComposition *laScene = [[LAComposition alloc] initWithJSON:animationJSON];
  return [[LAAnimationView alloc] initWithModel:laScene];
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
  self = [super initWithFrame:CGRectZero];
  if (self) {
    LAComposition *laScene = [[LAAnimationCache sharedCache] animationForKey:url.absoluteString];
    if (laScene) {
      [self _initializeAnimationContainer];
      [self _setupWithSceneModel:laScene restoreAnimationState:NO];
    } else {
      _animationState = [[LAAnimationState alloc] initWithDuration:singleFrameTimeValue layer:nil];
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
        
        LAComposition *laScene = [[LAComposition alloc] initWithJSON:animationJSON];
        dispatch_async(dispatch_get_main_queue(), ^(void){
          [[LAAnimationCache sharedCache] addAnimation:laScene forKey:url.absoluteString];
          [self _initializeAnimationContainer];
          [self _setupWithSceneModel:laScene restoreAnimationState:YES];
        });
      });
    }
  }
  return self;
}

- (instancetype)initWithModel:(LAComposition *)model {
  self = [super initWithFrame:model.compBounds];
  if (self) {
    [self _initializeAnimationContainer];
    [self _setupWithSceneModel:model restoreAnimationState:NO];
  }
  return self;
}

# pragma mark - Internal Methods

- (void)_initializeAnimationContainer {
  _animationContainer = [CALayer new];
  _animationContainer.masksToBounds = YES;
  [self.layer addSublayer:_animationContainer];
  self.clipsToBounds = YES;
}

- (void)_setupWithSceneModel:(LAComposition *)model restoreAnimationState:(BOOL)restoreAnimation {
  _sceneModel = model;
  [self _buildSubviewsFromModel];
  LAAnimationState *oldState = _animationState;
  _animationState = [[LAAnimationState alloc] initWithDuration:_sceneModel.timeDuration layer:_animationContainer];

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
    for (LACustomChild *child in _customLayers) {
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
  
  LALayerView *maskedLayer = nil;
  for (LALayer *layer in reversedItems) {
    LALayerView *layerView = [[LALayerView alloc] initWithModel:layer inComposition:_sceneModel];
    layerMap[layer.layerID] = layerView;
    layerNameMap[layer.layerName] = layerView;
    if (maskedLayer) {
      maskedLayer.mask = layerView;
      maskedLayer = nil;
    } else {
      if (layer.matteType == LAMatteTypeAdd) {
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
  
  for (LACustomChild *child in _customLayers) {
    switch (child.constraint) {
      case LAConstraintTypeAlignToLayer:
        child.childView.frame = child.layer.bounds;
        break;
      case LAConstraintTypeAlignToBounds: {
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

- (void)playWithCompletion:(LAAnimationCompletionBlock)completion {
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

- (void)addSubview:(UIView *)view
      toLayerNamed:(NSString *)layer {
  LAConstraintType constraint = LAConstraintTypeAlignToBounds;
  LALayerView *layerObject = _layerNameMap[layer];
  LACustomChild *newChild = [[LACustomChild alloc] init];
  newChild.constraint = constraint;
  newChild.childView = view;
  
  if (!layer) {
    // TODO Throw Error
    [self.layer addSublayer:view.layer];
    newChild.layer = self.layer;
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

- (void)removeFromSuperview {
  [self pause];
  [super removeFromSuperview];
}

- (void)setContentMode:(UIViewContentMode)contentMode {
  [super setContentMode:contentMode];
  [self setNeedsLayout];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  if (!hasFullyInitialized_) {
    _animationContainer.bounds = self.bounds;
    return;
  }
  
  CGPoint centerPoint = CGRectGetCenterPoint(self.bounds);
  CATransform3D xform;
  
  if (self.contentMode == UIViewContentModeScaleToFill) {
    CGSize scaleSize = CGSizeMake(self.bounds.size.width / self.sceneModel.compBounds.size.width,
                                  self.bounds.size.height / self.sceneModel.compBounds.size.height);
    xform = CATransform3DMakeScale(scaleSize.width, scaleSize.height, 1);
  } else if (self.contentMode == UIViewContentModeScaleAspectFit) {
    CGFloat compAspect = self.sceneModel.compBounds.size.width / self.sceneModel.compBounds.size.height;
    CGFloat viewAspect = self.bounds.size.width / self.bounds.size.height;
    BOOL scaleWidth = compAspect > viewAspect;
    CGFloat dominantDimension = scaleWidth ? self.bounds.size.width : self.bounds.size.height;
    CGFloat compDimension = scaleWidth ? self.sceneModel.compBounds.size.width : self.sceneModel.compBounds.size.height;
    CGFloat scale = dominantDimension / compDimension;
    xform = CATransform3DMakeScale(scale, scale, 1);
  } else if (self.contentMode == UIViewContentModeScaleAspectFill) {
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
