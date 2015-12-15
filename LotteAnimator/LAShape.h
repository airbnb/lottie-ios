//
//  LAShape.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "MTLModel.h"

@interface LAShape : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSArray *shapeItems;

@property (nonatomic, readonly) NSArray *paths;
@property (nonatomic, readonly) NSArray *strokes;
@property (nonatomic, readonly) NSArray *fills;
@property (nonatomic, readonly) NSArray *transforms;

@end
