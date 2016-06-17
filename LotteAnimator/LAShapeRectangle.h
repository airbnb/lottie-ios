//
//  LAShapeRectangle.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeItem.h"

@interface LAShapeRectangle : LAShapeItem

@property (nonatomic, copy) NSArray *positionArray;
@property (nonatomic, copy) NSArray *sizeArray;
@property (nonatomic, copy) NSNumber *cornerRadius;

@property (nonatomic, readonly) CGPoint position;
@property (nonatomic, readonly) CGSize size;

@end
