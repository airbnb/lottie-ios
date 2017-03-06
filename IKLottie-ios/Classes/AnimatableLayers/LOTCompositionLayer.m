//
//  LOTCompositionLayer.m
//  Pods
//
//  Created by Brandon Withrow on 2/17/17.
//
//

#import "LOTCompositionLayer.h"
#import "LOTPlatformCompat.h"
#import "LOTLayerView.h"
#import "LOTAnimationView_Internal.h"
#import "LOTAsset.h"
#import "LOTAssetGroup.h"

@interface LOTCustomChild : NSObject

@property (nonatomic, strong) LOTView *childView;
@property (nonatomic, weak) LOTLayerView *layer;
@property (nonatomic, assign) LOTConstraintType constraint;

@end

@implementation LOTCustomChild

@end

@implementation LOTCompositionLayer {
  NSDictionary *_layerMap;
  NSDictionary *_layerNameMap;
  NSMutableArray *_customLayers;
}

- (instancetype)initWithLayerGroup:(LOTLayerGroup *)layerGroup
                    withAssetGroup:(LOTAssetGroup *)assetGroup
                        withBounds:(CGRect)bounds {
  self = [super init];
  if (self) {
    self.masksToBounds = YES;
    [self _setupWithLayerGroup:layerGroup withAssetGroup:assetGroup withBounds:bounds];
  }
  return self;
}

- (void)_setupWithLayerGroup:(LOTLayerGroup *)layerGroup
              withAssetGroup:(LOTAssetGroup *)assetGroup
                  withBounds:(CGRect)bounds
               {
  if (_customLayers) {
    for (LOTCustomChild *child in _customLayers) {
      [child.childView.layer removeFromSuperlayer];
    }
    _customLayers = nil;
  }
  
  if (_layerMap) {
    _layerMap = nil;
    [self removeAllAnimations];
    [self.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
  }
  
  if (_layerNameMap) {
    _layerNameMap = nil;
  }

  self.bounds = bounds;
  
  NSMutableDictionary *layerMap = [NSMutableDictionary dictionary];
  NSMutableDictionary *layerNameMap = [NSMutableDictionary dictionary];
  
  NSArray *reversedItems = [[layerGroup.layers reverseObjectEnumerator] allObjects];
  
  CALayer *maskedLayer = nil;
  for (LOTLayer *layer in reversedItems) {
    LOTAsset *asset;
    
    if (layer.referenceID) {
      asset = [assetGroup assetModelForID:layer.referenceID];
    }
    
    LOTLayerView *layerView = [[LOTLayerView alloc] initWithModel:layer inLayerGroup:layerGroup];
    
    if (asset.layerGroup) {
      LOTCompositionLayer *precompLayer = [[LOTCompositionLayer alloc] initWithLayerGroup:asset.layerGroup
                                                                           withAssetGroup:assetGroup
                                                                               withBounds:layer.layerBounds];
      precompLayer.frame = layer.layerBounds;
      [layerView LOT_addChildLayer:precompLayer];
    }
    
    layerMap[layer.layerID] = layerView;
    layerNameMap[layer.layerName] = layerView;
    if (maskedLayer) {
      maskedLayer.mask = layerView;
      maskedLayer = nil;
    } else {
      if (layer.matteType == LOTMatteTypeAdd) {
        maskedLayer = layerView;
      }
      [self addSublayer:layerView];
    }
  }
  _layerMap = layerMap;
  _layerNameMap = layerNameMap;
}

- (void)layoutCustomChildLayers {
  if (!_customLayers.count) {
    return;
  }
  
  for (LOTCustomChild *child in _customLayers) {
    switch (child.constraint) {
      case LOTConstraintTypeAlignToLayer:
        child.childView.frame = child.layer.bounds;
        break;
      case LOTConstraintTypeAlignToBounds: {
        CGRect selfBounds = self.frame;
        CGRect convertedBounds = [child.childView.layer.superlayer convertRect:selfBounds fromLayer:self];
        child.childView.layer.frame = convertedBounds;
      } break;
      default:
        break;
    }
  }
}

- (void)addSublayer:(LOTView *)view
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
  [self layoutCustomChildLayers];
}

@end
