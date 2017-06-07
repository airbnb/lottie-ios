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
  NSDictionary<NSString *, UIImage *> *_customImages;
}

- (instancetype)initWithJSON:(NSArray *)jsonArray {
    return [self initWithJSON:jsonArray customImages:nil];
}

- (instancetype)initWithJSON:(NSArray *)jsonArray customImages:(NSDictionary *)customImages {
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
    _customImages = customImages;
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

- (UIImage *)imageForName:(NSString *)imageName {
    return _customImages[imageName];
}

@end
