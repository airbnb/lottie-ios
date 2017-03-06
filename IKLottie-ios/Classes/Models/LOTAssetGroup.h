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
@interface LOTAssetGroup : NSObject

- (instancetype _Nonnull)initWithJSON:(NSArray * _Nonnull)jsonArray;

- (void)buildAssetNamed:(NSString * _Nonnull)refID
             withBounds:(CGRect)bounds
           andFramerate:(NSNumber * _Nullable)framerate;

- (void)finalizeInitialization;

- (LOTAsset * _Nullable)assetModelForID:(NSString * _Nonnull)assetID;

@end
