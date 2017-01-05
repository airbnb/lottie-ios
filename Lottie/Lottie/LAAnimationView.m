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

const NSTimeInterval singleFrameTimeValue = 1.0 / 60.0;

@implementation LAAnimationState {
  BOOL _animationIsPlaying;
  BOOL _resetOnPlay;
}

- (void)updateAnimationLayer {
  self.layer.repeatCount = _loopAnimation ? HUGE_VALF : 0;
  self.layer.beginTime = 0;
  self.layer.timeOffset = 0;
  
  self.layer.duration = self.animationDuration;
  self.layer.speed = self.layerSpeed;
  self.layer.beginTime = self.layerBeginTime;
  self.layer.timeOffset = self.layerTimeOffset;
}

- (void)setAnimationIsPlaying:(BOOL)animationIsPlaying {
  if (_animationIsPlaying == animationIsPlaying) {
    return;
  }
  _animationIsPlaying = animationIsPlaying;
  
  if (_animationIsPlaying) {
    // Play
    _startTimeAbsolute = CACurrentMediaTime() - _layerTimeOffset;
    _layerTimeOffset = 0;
    _layerSpeed = _animationSpeed;
    _layerBeginTime = _startTimeAbsolute;
    
    if (_resetOnPlay) {
      _resetOnPlay = NO;
      _startTimeAbsolute = CACurrentMediaTime();
      _layerTimeOffset = 0;
      _layerBeginTime = _startTimeAbsolute;
    }
  } else {
    // Pause
    _pauseTimeAbsolute = CACurrentMediaTime();
    CGFloat relativeTimeDiff = _pauseTimeAbsolute - _startTimeAbsolute;
    
    _layerTimeOffset = relativeTimeDiff - (floor(relativeTimeDiff / _animationDuration) * _animationDuration);
    _layerSpeed = 0;
    _layerBeginTime = 0;
  }
  [self updateAnimationLayer];
}

- (void)setAnimatedProgress:(CGFloat)animatedProgress {
  if (_animatedProgress == animatedProgress && !_animationIsPlaying) {
    return;
  }
  
  if (_resetOnPlay) {
    _resetOnPlay = NO;
  }

  _animationIsPlaying = NO;
  _pauseTimeAbsolute = 0;
  _startTimeAbsolute = 0;
  
  CGFloat modifiedProgress = animatedProgress - floor(animatedProgress);
  _layerTimeOffset = modifiedProgress * _animationDuration;
  _layerSpeed = 0;
  _layerBeginTime = 0;
  
  
  _animatedProgress = animatedProgress;
  [self updateAnimationLayer];
}

- (void)setAnimationSpeed:(CGFloat)speed {
  _animationSpeed = speed;
  _layerSpeed = _animationIsPlaying ? _animationSpeed : 0;
  if (_animationIsPlaying) {
    [self updateAnimationLayer];
  }
}

- (void)setAnimationDoesLoop:(BOOL)loopAnimation {
  _loopAnimation = loopAnimation;
  if (_resetOnPlay) {
    _resetOnPlay = NO;
  }
  [self updateAnimationLayer];
}

- (id)initWithDuration:(CGFloat)duration layer:(CALayer *)layer{
  self = [super init];
  if (self) {
    _layer = layer;
    _animationIsPlaying = NO;
    _loopAnimation = NO;
    
    _startTimeAbsolute = CACurrentMediaTime();
    _pauseTimeAbsolute = CACurrentMediaTime();
    
    _animationDuration = duration;
    _animatedProgress = 0;
    _animationSpeed = 1;
    _layerTimeOffset = 0;
    _layerBeginTime = 0;
    _layerSpeed = 0;
    [self updateAnimationLayer];
  }
  return self;
}

- (BOOL)animationIsPlaying {
  if (_animationIsPlaying && !_loopAnimation) {
    CGFloat timeDiff = CACurrentMediaTime() - _startTimeAbsolute;
    if (timeDiff > (_animationDuration * _animationSpeed)) {
      _animationIsPlaying = NO;
      _resetOnPlay = YES;
    }
  }
  return _animationIsPlaying;
}

@end

@implementation LAAnimationView {
  NSDictionary *_layerMap;
  CALayer *_animationContainer;
  CADisplayLink *_completionDisplayLink;
}

# pragma mark - Initializers

+ (instancetype)animationNamed:(NSString *)animationName {
  NSError *error;
  NSString *filePath = [[NSBundle mainBundle] pathForResource:animationName ofType:@"json"];
  NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];
  NSDictionary  *JSONObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:0 error:&error];
  return [LAAnimationView animationFromJSON:JSONObject];
}

+ (instancetype)animationFromJSON:(NSDictionary *)animationJSON {
  LAComposition *laScene = [[LAComposition alloc] initWithJSON:animationJSON];
  return [[LAAnimationView alloc] initWithModel:laScene];
}

- (instancetype)initWithModel:(LAComposition *)model {
  self = [super initWithFrame:model.compBounds];
  if (self) {
    _sceneModel = model;
    _animationContainer = [CALayer new];
    _animationContainer.frame = self.bounds;
    _animationContainer.fillMode = kCAFillModeForwards;
    _animationContainer.masksToBounds = YES;
    [self.layer addSublayer:_animationContainer];
    [self _buildSubviewsFromModel];
    self.clipsToBounds = YES;

    _animationState = [[LAAnimationState alloc] initWithDuration:self.sceneModel.timeDuration + singleFrameTimeValue layer:_animationContainer];
  }
  return self;
}

# pragma mark - Internal Methods

- (void)_buildSubviewsFromModel {
  NSMutableDictionary *layerMap = [NSMutableDictionary dictionary];
  
  NSArray *reversedItems = [[_sceneModel.layers reverseObjectEnumerator] allObjects];
  
  LALayerView *maskedLayer = nil;
  for (LALayer *layer in reversedItems) {
    LALayerView *layerView = [[LALayerView alloc] initWithModel:layer inComposition:_sceneModel];
    layerMap[layer.layerID] = layerView;
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
}

# pragma mark - External Methods

- (void)play {
  [self playWithCompletion:nil];
}

- (void)playWithCompletion:(void (^)(void))completion {
  if (_animationState.animationIsPlaying == NO) {
    self.completionBlock = completion;
    [_animationState setAnimationIsPlaying:YES];
    [self startDisplayLink];
  }
}

- (void)pause {
  if (_animationState.animationIsPlaying) {
    [_animationState setAnimationIsPlaying:NO];
    [self stopDisplayLink];
  }
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
    if (self.completionBlock) {
      self.completionBlock();
      self.completionBlock = nil;
    }
  }
}

# pragma mark - Getters and Setters

- (void)setAnimationProgress:(CGFloat)animationProgress {
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

# pragma mark - Overrides

- (void)didMoveToSuperview {
  [super didMoveToSuperview];
  [_animationState updateAnimationLayer];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
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
  
  _animationContainer.transform = xform;
  _animationContainer.position = centerPoint;
  [CATransaction commit];
}

@end
