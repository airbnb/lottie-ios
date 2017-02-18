//
//  LOTCompositionLayer.h
//  Pods
//
//  Created by Brandon Withrow on 2/17/17.
//
//

#import <QuartzCore/QuartzCore.h>
@class LOTLayerGroup;

@interface LOTCompositionLayer : CALayer

- (instancetype)initWithLayerGroup:(LOTLayerGroup *)layerGroup;

@end
