//
//  LAShapePath.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapeItem.h"

@interface LAShapePath : LAShapeItem

@property (nonatomic, getter=isClosed) BOOL closed;
@property (nonatomic, strong) LAPath *shapePath;

@end
