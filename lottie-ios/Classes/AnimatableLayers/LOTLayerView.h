//
//  LOTLayerView.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTPlatformCompat.h"
#import "LOTAnimatableLayer.h"

#import "LOTModels.h"

@interface LOTLayerView : LOTAnimatableLayer

- (instancetype)initWithModel:(LOTLayer *)model inLayerGroup:(LOTLayerGroup *)layerGroup;

- (void)LOT_addChildLayer:(CALayer *)childLayer;

@property (nonatomic, readonly) LOTLayer *layerModel;
@property (nonatomic, assign) BOOL debugModeOn;

@end
