//
//  LOTAsset.h
//  Pods
//
//  Created by Brandon Withrow on 2/16/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class LOTLayerGroup;
@class LOTLayer;
@class LOTAssetGroup;

@interface LOTAsset : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary
                  withBounds:(CGRect)bounds
               withFramerate:(NSNumber * _Nullable)framerate
              withAssetGroup:(LOTAssetGroup * _Nullable)assetGroup;

@property (nonatomic, readonly, nullable) NSString *referenceID;
@property (nonatomic, readonly, nullable) NSNumber *assetWidth;
@property (nonatomic, readonly, nullable) NSNumber *assetHeight;

@property (nonatomic, readonly, nullable) NSString *imageName;
@property (nonatomic, readonly, nullable) NSString *imageDirectory;

@property (nonatomic, readonly, nullable) LOTLayerGroup *layerGroup;

@end

NS_ASSUME_NONNULL_END
