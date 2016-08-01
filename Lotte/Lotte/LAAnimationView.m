//
//  LAAnimationView
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAAnimationView.h"
#import "LALayerView.h"
#import "LAModels.h"
#import "LAHelpers.h"

@interface LAAnimationView ()

@property (nonatomic, readonly) LAComposition *sceneModel;

@end

@implementation LAAnimationView {
  NSDictionary *_layerMap;
  CALayer *_animationContainer;
}

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
    _animationSpeed = 1;
    _animationContainer = [CALayer new];
    _animationContainer.frame = self.bounds;
    _animationContainer.speed = 0;
    _animationContainer.fillMode = kCAFillModeForwards;
    _animationContainer.masksToBounds = YES;
    [self.layer addSublayer:_animationContainer];
    [self _buildSubviewsFromModel];
    self.clipsToBounds = YES;
  }
  return self;
}

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

- (void)playWithCompletion:(void (^)(void))completion {
  [CATransaction begin];
  _animationContainer.speed = self.animationSpeed;
  _animationContainer.duration = self.sceneModel.timeDuration;
  _animationContainer.beginTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
  [CATransaction setAnimationDuration:self.sceneModel.timeDuration];
  if (completion) {
    [CATransaction setCompletionBlock:completion];
  }
  [CATransaction commit];
}

- (void)play {
  [self playWithCompletion:nil];
}

- (void)pause {
  _animationContainer.speed = 0;
}

- (void)setAnimationProgress:(CGFloat)animationProgress {
  _animationProgress = animationProgress;
  
  _animationContainer.speed = 0;
  _animationContainer.timeOffset = 0.0;
  _animationContainer.duration = self.sceneModel.timeDuration;
  _animationContainer.beginTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
  _animationContainer.timeOffset = animationProgress * self.sceneModel.timeDuration;
}

- (void)setLoopAnimation:(BOOL)loopAnimation {
  _loopAnimation = loopAnimation;
  _animationContainer.repeatCount = loopAnimation ? HUGE_VALF : 0;
}

- (void)setAutoReverseAnimation:(BOOL)autoReverseAnimation {
  _autoReverseAnimation = autoReverseAnimation;
  _animationContainer.autoreverses = autoReverseAnimation;
}

-(void)setAnimationSpeed:(CGFloat)animationSpeed {
  _animationSpeed = animationSpeed;
  if (self.isAnimationPlaying) {
    _animationContainer.speed = animationSpeed;
  }
}

- (BOOL)isAnimationPlaying {
  return _animationContainer.speed > 0;
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
