//
//  LOTComposition.m
//  LottieAnimator
//
//  Created by Brandon Withrow on 12/14/15.
//  Copyright © 2015 Brandon Withrow. All rights reserved.
//

#import "LOTComposition.h"
#import "LOTComposition_Internal.h"
#import "LOTLayer.h"
#import "LOTAssetGroup.h"
#import "LOTLayerGroup.h"
#import "LOTAnimationCache.h"

@implementation LOTComposition

+ (instancetype)compositionForAnimationNamed:(NSString *)animationName inBundle:(NSBundle *)bundle {
    NSArray *components = [animationName componentsSeparatedByString:@"."];
    if (components.count > 2) {
        NSLog(@"%s: Warning: only one period [.] is supported in the name: %@", __PRETTY_FUNCTION__, animationName);
    }
    animationName = components.firstObject;

    NSError *error;
    LOTComposition *composition = [[LOTAnimationCache sharedCache] animationForKey:animationName];
    if (composition == nil) {
        NSString *filePath = [bundle pathForResource:animationName ofType:@"json"];
        if (filePath == nil) {
            NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Animation not found: %@", @""), animationName];
            NSDictionary *info = @{NSLocalizedDescriptionKey: text};
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:info];
        } else {
            NSData *jsonData = [[NSData alloc] initWithContentsOfFile:filePath];

            NSDictionary  *JSONObject = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                   options:0 error:&error] : nil;
            if (JSONObject && !error) {
                composition = [[self alloc] initWithJSON:JSONObject];
                [[LOTAnimationCache sharedCache] addAnimation:composition forKey:animationName];
            }
        }
    }

    if (error) {
        NSLog(@"%s: Unable to load animation: %@", __PRETTY_FUNCTION__, error);
        [NSException raise:@"ResourceNotLoadedException" format:@"%@", [error localizedDescription]];
    }

    return composition;
}

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {
  NSNumber *width = jsonDictionary[@"w"];
  NSNumber *height = jsonDictionary[@"h"];
  if (width && height) {
    CGRect bounds = CGRectMake(0, 0, width.floatValue, height.floatValue);
    _compBounds = bounds;
  }
  
  _startFrame = [jsonDictionary[@"ip"] copy];
  _endFrame = [jsonDictionary[@"op"] copy];
  _framerate = [jsonDictionary[@"fr"] copy];
  
  if (_startFrame && _endFrame && _framerate) {
    NSInteger frameDuration = _endFrame.integerValue - _startFrame.integerValue;
    NSTimeInterval timeDuration = frameDuration / _framerate.floatValue;
    _timeDuration = timeDuration;
  }
  
  NSArray *assetArray = jsonDictionary[@"assets"];
  if (assetArray.count) {
    _assetGroup = [[LOTAssetGroup alloc] initWithJSON:assetArray];
  }
  
  NSArray *layersJSON = jsonDictionary[@"layers"];
  if (layersJSON) {
    _layerGroup = [[LOTLayerGroup alloc] initWithLayerJSON:layersJSON
                                                withBounds:_compBounds
                                             withFramerate:_framerate
                                            withAssetGroup:_assetGroup];
  }
  
  [_assetGroup finalizeInitialization];

}

@end
