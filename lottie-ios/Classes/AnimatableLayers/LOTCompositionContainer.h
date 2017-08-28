//
//  LOTCompositionContainer.h
//  Lottie
//
//  Created by brandon_withrow on 7/18/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTLayerContainer.h"
#import "LOTAssetGroup.h"

@interface LOTCompositionContainer : LOTLayerContainer

- (instancetype _Nonnull)initWithModel:(LOTLayer * _Nullable)layer
                          inLayerGroup:(LOTLayerGroup * _Nullable)layerGroup
                        withLayerGroup:(LOTLayerGroup * _Nullable)childLayerGroup
                       withAssestGroup:(LOTAssetGroup * _Nullable)assetGroup;

- (void)addSublayer:(nonnull CALayer *)subLayer
       toLayerNamed:(nonnull NSString *)layerName
     applyTransform:(BOOL)applyTransform;

- (CGRect)convertRect:(CGRect)rect
            fromLayer:(CALayer *_Nonnull)fromlayer
         toLayerNamed:(NSString *_Nonnull)layerName;

@property (nonatomic, readonly, nonnull) NSArray<LOTLayerContainer *> *childLayers;
@property (nonatomic, readonly, nonnull)  NSDictionary *childMap;

@end
