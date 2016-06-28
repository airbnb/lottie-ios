//
//  LAAnimatableProperty.h
//  LotteAnimator
//
//  Created by brandon_withrow on 6/22/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

// Make animatatable property class for each type of property
// Number
// Point (can be either linear animation or path driven animation)
// Color
// Path


@protocol LAAnimatableValue <NSObject>

@property (nonatomic, readonly) NSString *keyPath;
@property (nonatomic, readonly) CAKeyframeAnimation *animation;

@end
