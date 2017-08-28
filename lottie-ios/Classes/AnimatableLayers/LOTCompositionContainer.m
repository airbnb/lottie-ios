//
//  LOTCompositionContainer.m
//  Lottie
//
//  Created by brandon_withrow on 7/18/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTCompositionContainer.h"
#import "LOTAsset.h"
#import "CGGeometry+LOTAdditions.h"
#import "LOTHelpers.h"

@implementation LOTCompositionContainer {
  NSNumber *_frameOffset;
  CALayer *DEBUG_Center;
}

- (instancetype)initWithModel:(LOTLayer *)layer
                 inLayerGroup:(LOTLayerGroup *)layerGroup
               withLayerGroup:(LOTLayerGroup *)childLayerGroup
              withAssestGroup:(LOTAssetGroup *)assetGroup {
  self = [super initWithModel:layer inLayerGroup:layerGroup];
  if (self) {
    DEBUG_Center = [CALayer layer];
    
    DEBUG_Center.bounds = CGRectMake(0, 0, 20, 20);
    DEBUG_Center.borderColor = [UIColor orangeColor].CGColor;
    DEBUG_Center.borderWidth = 2;
    DEBUG_Center.masksToBounds = YES;
    if (ENABLE_DEBUG_SHAPES) {
      [self.wrapperLayer addSublayer:DEBUG_Center];
    }
    if (layer.startFrame) {
      _frameOffset = layer.startFrame;
    } else {
      _frameOffset = @0;
    }
    [self intializeWithChildGroup:childLayerGroup withAssetGroup:assetGroup];
  }
  return self;
}

- (void)intializeWithChildGroup:(LOTLayerGroup *)childGroup
                 withAssetGroup:(LOTAssetGroup *)assetGroup {
  NSMutableDictionary *childMap = [NSMutableDictionary dictionary];
  NSMutableArray *children = [NSMutableArray array];
  NSArray *reversedItems = [[childGroup.layers reverseObjectEnumerator] allObjects];
  
  CALayer *maskedLayer = nil;
  for (LOTLayer *layer in reversedItems) {
    LOTAsset *asset;
    if (layer.referenceID) {
      // Get relevant Asset
      asset = [assetGroup assetModelForID:layer.referenceID];
    }
    
    LOTLayerContainer *child = nil;
    if (asset.layerGroup) {
      // Layer is a precomp
      LOTCompositionContainer *compLayer = [[LOTCompositionContainer alloc] initWithModel:layer inLayerGroup:childGroup withLayerGroup:asset.layerGroup withAssestGroup:assetGroup];
      child = compLayer;
    } else {
      child = [[LOTLayerContainer alloc] initWithModel:layer inLayerGroup:childGroup];
    }
    if (maskedLayer) {
      maskedLayer.mask = child;
      maskedLayer = nil;
    } else {
      if (layer.matteType == LOTMatteTypeAdd) {
        maskedLayer = child;
      }
      [self.wrapperLayer addSublayer:child];
    }
    [children addObject:child];
    if (child.layerName) {
      [childMap setObject:child forKey:child.layerName];
    }
  }
  _childMap = childMap;
  _childLayers = children;
}

- (void)displayWithFrame:(NSNumber *)frame forceUpdate:(BOOL)forceUpdate {
  if (ENABLE_DEBUG_LOGGING) NSLog(@"-------------------- Composition Displaying Frame %@ --------------------", frame);
  [super displayWithFrame:frame forceUpdate:forceUpdate];
  NSNumber *childFrame = @(frame.floatValue - _frameOffset.floatValue);
  for (LOTLayerContainer *child in _childLayers) {
    [child displayWithFrame:childFrame forceUpdate:forceUpdate];
  }
  if (ENABLE_DEBUG_LOGGING) NSLog(@"-------------------- ------------------------------- --------------------");
  if (ENABLE_DEBUG_LOGGING) NSLog(@"-------------------- ------------------------------- --------------------");

}

- (BOOL)setValue:(nonnull id)value
      forKeypath:(nonnull NSString *)keypath
         atFrame:(nullable NSNumber *)frame {
  BOOL transformSet = [super setValue:value forKeypath:keypath atFrame:frame];
  if (transformSet) {
    return transformSet;
  }
  NSString *childKey = nil;
  if (self.layerName == nil) {
    childKey = keypath;
  } else {
    NSArray *components = [keypath componentsSeparatedByString:@"."];
    NSString *firstKey = components.firstObject;
    if ([firstKey isEqualToString:self.layerName]) {
      childKey = [keypath stringByReplacingCharactersInRange:NSMakeRange(0, firstKey.length + 1) withString:@""];
    }
  }

  if (childKey) {
    for (LOTLayerContainer *child in _childLayers) {
      BOOL childHasKey = [child setValue:value forKeypath:childKey atFrame:frame];
      if (childHasKey) {
        return childHasKey;
      }
    }
  }
  return NO;
}

- (void)addSublayer:(nonnull CALayer *)subLayer
       toLayerNamed:(nonnull NSString *)layerName
     applyTransform:(BOOL)applyTransform {
  LOTLayerContainer *child = _childMap[layerName];
  if (child) {
    if (applyTransform) {
      [child addAndMaskSublayer:subLayer];
    } else {
      CALayer *maskWrapper = [CALayer new];
      [maskWrapper addSublayer:subLayer];
      [self.wrapperLayer insertSublayer:maskWrapper below:child];
      [child removeFromSuperlayer];
      maskWrapper.mask = child;
    }
  }
}

- (CGRect)convertRect:(CGRect)rect
            fromLayer:(CALayer *_Nonnull)fromlayer
         toLayerNamed:(NSString *_Nonnull)layerName {
  CGRect xRect = rect;
  LOTLayerContainer *child = _childMap[layerName];
  if (child) {
    xRect = [fromlayer convertRect:rect toLayer:child];
  }
  return xRect;
}

- (void)setViewportBounds:(CGRect)viewportBounds {
  [super setViewportBounds:viewportBounds];
  for (LOTLayerContainer *layer in _childLayers) {
    layer.viewportBounds = viewportBounds;
  }
}

- (void)logHierarchyKeypathsWithParent:(NSString * _Nullable)parent {
  NSString *keypath = parent;
  if (parent && self.layerName) {
    keypath = [NSString stringWithFormat:@"%@.%@", parent, self.layerName];
  }  
  for (LOTLayerContainer *layer in _childLayers) {
    [layer logHierarchyKeypathsWithParent:keypath];
  }
}

@end
