//
//  LAMask.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAMask.h"

@implementation LAMask

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{@"closed" : @"cl",
           @"inverted" : @"inv",
           @"maskPath" : @"pt",
           @"opacity" : @"o"};
}

+ (NSValueTransformer *)maskPathJSONTransformer {
  // tell Mantle to populate diaAttributes property with an array of MDAttribute objects
  return [MTLJSONAdapter dictionaryTransformerWithModelClass:[LAPath class]];
}

+ (NSValueTransformer *)closedJSONTransformer {
  return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (NSValueTransformer *)invertedJSONTransformer {
  return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

@end
