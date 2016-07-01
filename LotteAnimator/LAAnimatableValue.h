//
//  LAAnimatableProperty.h
//  LotteAnimator
//
//  Created by brandon_withrow on 6/22/16.
//  Copyright © 2016 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LAAnimatableValue <NSObject>

@property (nonatomic, readonly) NSString *keyPath;
@property (nonatomic, readonly) CAKeyframeAnimation *animation;

@end
