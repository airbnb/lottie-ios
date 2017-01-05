//
//  LALayerView.h
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LAAnimatableLayer.h"

#import "LAModels.h"

@interface LALayerView : LAAnimatableLayer

- (instancetype)initWithModel:(LALayer *)model inComposition:(LAComposition *)comp;

@property (nonatomic, readonly) LALayer *layerModel;
@property (nonatomic, assign) BOOL debugModeOn;

@end
