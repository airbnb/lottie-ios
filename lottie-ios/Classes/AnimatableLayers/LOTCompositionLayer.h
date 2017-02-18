//
//  LOTCompositionLayer.h
//  Pods
//
//  Created by Brandon Withrow on 2/17/17.
//
//

#import <QuartzCore/QuartzCore.h>
#import "LOTAnimationView_Compat.h"

@class LOTLayerGroup;

@interface LOTCompositionLayer : CALayer

- (instancetype)initWithLayerGroup:(LOTLayerGroup *)layerGroup
                        withBounds:(CGRect)bounds;

- (void)addSublayer:(LOTView *)view
       toLayerNamed:(NSString *)layer;

- (void)layoutCustomChildLayers;

@end
