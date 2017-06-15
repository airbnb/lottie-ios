//
//  LOTLayerGroup.h
//  Pods
//
//  Created by Brandon Withrow on 2/16/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class LOTLayer;
@class LOTAssetGroup;

@interface LOTLayerGroup : NSObject

- (instancetype)initWithLayerJSON:(NSArray *)layersJSON
                       withBounds:(CGRect)bounds
                    withFramerate:(NSNumber * _Nullable)framerate
                   withAssetGroup:(LOTAssetGroup * _Nullable)assetGroup;

@property (nonatomic, readonly) NSArray <LOTLayer *> *layers;

- (LOTLayer *)layerModelForID:(NSNumber *)layerID;
- (LOTLayer *)layerForReferenceID:(NSString *)referenceID;

@end

NS_ASSUME_NONNULL_END
