//
//  LOTLayerContainer.h
//  Lottie
//
//  Created by brandon_withrow on 7/18/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTPlatformCompat.h"
#import "LOTLayer.h"
#import "LOTLayerGroup.h"
#import "LOTKeypath.h"
#import "LOTValueCallback.h"

@interface LOTLayerContainer : CALayer

- (instancetype _Nonnull)initWithModel:(LOTLayer * _Nullable)layer
                 inLayerGroup:(LOTLayerGroup * _Nullable)layerGroup;

@property (nonatomic,  readonly, strong, nullable) NSString *layerName;
@property (nonatomic, nullable) NSNumber *currentFrame;
@property (nonatomic, assign) CGRect viewportBounds;
@property (nonatomic, readonly, nonnull) CALayer *wrapperLayer;
@property (nonatomic, readonly, nonnull) NSDictionary *valueInterpolators;
- (void)displayWithFrame:(NSNumber * _Nonnull)frame;
- (void)displayWithFrame:(NSNumber * _Nonnull)frame forceUpdate:(BOOL)forceUpdate;

- (void)addAndMaskSublayer:(nonnull CALayer *)subLayer __deprecated;

- (BOOL)setValue:(nonnull id)value
      forKeypath:(nonnull NSString *)keypath
         atFrame:(nullable NSNumber *)frame __deprecated;

- (void)logHierarchyKeypathsWithParent:(NSString * _Nullable)parent __deprecated;

- (void)searchNodesForKeypath:(LOTKeypath * _Nonnull)keypath;

- (void)setValueCallback:(nonnull LOTValueCallback *)callbackBlock
              forKeypath:(nonnull LOTKeypath *)keypath;

@end
