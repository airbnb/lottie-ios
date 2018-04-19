//
//  LOTTextDocument.m
//  Lottie
//
//  Created by Adam Tierney on 4/18/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import "LOTTextDocument.h"
#import "UIColor+Expanded.h"

@implementation LOTTextDocument

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {
  NSArray *keyframesJSON = jsonDictionary[@"k"];
  NSMutableArray *keyframes = [NSMutableArray array];
  for (NSDictionary *keyframeJSON in keyframesJSON) {
    id newKeyframe = [[LOTTextDocumentKeyframe alloc] initWithJSON:keyframeJSON];
    if (newKeyframe) {
      [keyframes addObject:newKeyframe];
    }
  }
  _keyframes = keyframes;
}

@end

@implementation LOTTextDocumentKeyframe : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {
  _keyframeTime = jsonDictionary[@"t"];
  NSDictionary *documentInfo = jsonDictionary[@"s"];
  _fontName = documentInfo[@"f"];
  _justification = documentInfo[@"j"];
  _lineHeight = documentInfo[@"lh"];
  _fontSize = documentInfo[@"s"];
  _text = documentInfo[@"t"];
  _tracking = documentInfo[@"tr"];
  _fontColor = [UIColor LOT_colorFromRGBAArray:documentInfo[@"fc"]];
}

@end
