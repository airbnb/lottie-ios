//
//  LAShapePath.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/15/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAShapePath.h"

@implementation LAShapePath

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{@"itemType" : @"ty",
           @"closed" : @"closed",
           @"shapePath" : @"ks"};
}

+ (NSValueTransformer *)shapePathJSONTransformer {
  // tell Mantle to populate diaAttributes property with an array of MDAttribute objects
  return [MTLJSONAdapter dictionaryTransformerWithModelClass:[LAPath class]];
}

+ (NSValueTransformer *)closedJSONTransformer {
  return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

- (UIBezierPath *)path {
  return [self.shapePath bezierPath:self.isClosed];
}
@end
