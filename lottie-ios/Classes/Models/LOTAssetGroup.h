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

- (instancetype)initWithJSON:(NSArray *)jsonArray;

- (void)buildAssetNamed:(NSString *)refID
             withBounds:(CGRect)bounds
           andFramerate:(NSNumber * _Nullable)framerate;

- (void)finalizeInitialization;

- (LOTAsset *)assetModelForID:(NSNumber *)assetID;

@end
