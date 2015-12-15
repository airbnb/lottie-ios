//
//  LAScene.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "MTLModel.h"

@class LALayer;
@interface LAScene : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSArray <LALayer *> *layers;
@property (nonatomic, strong) NSNumber *compWidth;
@property (nonatomic, strong) NSNumber *compHeight;

@end
