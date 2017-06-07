//
//  LOTAssetGroup.m
//  Pods
//
//  Created by Brandon Withrow on 2/17/17.
//
//

#import "LOTAssetGroup.h"
#import "LOTAsset.h"

@implementation LOTAssetGroup {
  NSMutableDictionary<NSString *, LOTAsset *> *_assetMap;
  NSDictionary<NSString *, NSDictionary *> *_assetJSONMap;
  NSString *_resFilePath;
}

- (instancetype)initWithJSON:(NSArray *)jsonArray resFilePath:(NSString *)resFilePath {
  self = [super init];
  if (self) {
    _assetMap = [NSMutableDictionary dictionary];
    NSMutableDictionary *assetJSONMap = [NSMutableDictionary dictionary];
    for (NSDictionary<NSString *, NSString *> *assetDictionary in jsonArray) {
      NSString *referenceID = assetDictionary[@"id"];
      if (referenceID) {
        assetJSONMap[referenceID] = assetDictionary;
      }
    }
    _assetJSONMap = assetJSONMap;
    _resFilePath = resFilePath;
  }
  return self;
}

- (void)buildAssetNamed:(NSString *)refID
             withBounds:(CGRect)bounds
           andFramerate:(NSNumber * _Nullable)framerate {
  
  if ([self assetModelForID:refID]) {
    return;
  }
  
  NSDictionary *assetDictionary = _assetJSONMap[refID];
  if (assetDictionary) {
    LOTAsset *asset = [[LOTAsset alloc] initWithJSON:assetDictionary
                                       imageFilePath:_resFilePath
                                          withBounds:bounds
                                       withFramerate:framerate
                                      withAssetGroup:self];
    _assetMap[refID] = asset;
  }
}

- (void)finalizeInitialization {
  for (NSString *refID in _assetJSONMap.allKeys) {
    [self buildAssetNamed:refID withBounds:CGRectZero andFramerate:nil];
  }
  _assetJSONMap = nil;
}

- (LOTAsset *)assetModelForID:(NSString *)assetID {
  return _assetMap[assetID];
}

@end
