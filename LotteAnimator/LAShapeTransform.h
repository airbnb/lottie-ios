//
//  LAShapeTransform.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeItem.h"

@interface LAShapeTransform : LAShapeItem

@property (nonatomic, copy) NSArray *positionArray;
@property (nonatomic, copy) NSArray *anchorPointArray;
@property (nonatomic, copy) NSArray *scaleArray;
@property (nonatomic, copy) NSNumber *rotation;
@property (nonatomic, copy) NSNumber *opacity;

@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, readonly) CGPoint anchorPoint;
@property (nonatomic, readonly) CGSize scale;
@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) CGAffineTransform transform;

@end
