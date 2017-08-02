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

@end
