//
//  LAScene.m
//  LotteAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LAScene.h"
#import "LALayer.h"

@implementation LAScene

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
  return @{@"compWidth" : @"w",
           @"compHeight" : @"h",
           @"framerate" : @"fr",
           @"startFrame" : @"ip",
           @"endFrame" : @"op",
           @"layers" : @"layers"};
}

+ (NSValueTransformer *)layersJSONTransformer {
  // tell Mantle to populate diaAttributes property with an array of MDAttribute objects
  return [MTLJSONAdapter arrayTransformerWithModelClass:[LALayer class]];
}

@end
