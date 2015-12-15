//
//  LAMask.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "MTLModel.h"

@interface LAMask : MTLModel <MTLJSONSerializing>

@property (nonatomic, getter=isClosed) BOOL closed;
@property (nonatomic, getter=isInverted) BOOL inverted;
@property (nonatomic, strong) LAPath *maskPath;
@property (nonatomic, copy) NSNumber *opacity;

@end
