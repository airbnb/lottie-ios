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

- (instancetype)initWithModel:(LOTLayer *)layer
                 inLayerGroup:(LOTLayerGroup *)layerGroup
               withLayerGroup:(LOTLayerGroup *)childLayerGroup
              withAssestGroup:(LOTAssetGroup *)assetGroup;

@end
