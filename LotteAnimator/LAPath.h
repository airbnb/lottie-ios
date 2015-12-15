//
//  LABezierPath.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "MTLModel.h"

@interface LAPath : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSArray *points;
@property (nonatomic, strong) NSArray *inTangents;
@property (nonatomic, strong) NSArray *outTangents;

- (UIBezierPath *)bezierPath:(BOOL)closedPath;

@end
