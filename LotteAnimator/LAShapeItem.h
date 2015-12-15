//
//  LAShapeItem.h
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "MTLModel.h"

struct LAShapeItemType {
  __unsafe_unretained NSString * const Path;
  __unsafe_unretained NSString * const Stroke;
  __unsafe_unretained NSString * const Fill;
  __unsafe_unretained NSString * const Transform;
};

extern const struct LAShapeItemType LAShapeItemType;

@interface LAShapeItem : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *itemType;

@end
