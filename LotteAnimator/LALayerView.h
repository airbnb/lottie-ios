//
//  LALayerView.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LAModels.h"

@interface LALayerView : UIView

- (instancetype)initWithModel:(LALayer *)model;

@property (nonatomic, readonly) LALayer *layerModel;
@property (nonatomic, assign) BOOL debugModeOn;

- (void)startAnimation;

@end
