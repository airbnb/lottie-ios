//
//  LAShapeFill.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeItem.h"

@interface LAShapeFill : LAShapeItem

@property (nonatomic, getter=isFillEnabled) BOOL fillEnabled;
@property (nonatomic, copy) NSArray *colorElements;
@property (nonatomic, copy) NSNumber *opacity;

@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, readonly) CGFloat alpha;
@end
