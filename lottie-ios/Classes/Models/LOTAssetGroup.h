//
//  LOTAssetGroup.h
//  Pods
//
//  Created by Brandon Withrow on 2/17/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class LOTAsset;
@class LOTLayerGroup;
@class UIImage;
@interface LOTAssetGroup : NSObject

- (instancetype _Nonnull)initWithJSON:(NSArray * _Nonnull)jsonArray;
- (instancetype _Nonnull)initWithJSON:(NSArray * _Nonnull)jsonArray customImages:(NSDictionary *)customImages;

- (void)buildAssetNamed:(NSString * _Nonnull)refID
             withBounds:(CGRect)bounds
           andFramerate:(NSNumber * _Nullable)framerate;

- (void)finalizeInitialization;

- (LOTAsset * _Nullable)assetModelForID:(NSString * _Nonnull)assetID;
- (UIImage *)imageForName:(NSString *)imageName;

@end
