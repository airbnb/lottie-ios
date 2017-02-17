//
//  LOTLayerGroup.h
//  Pods
//
//  Created by Brandon Withrow on 2/16/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class LOTLayer;

@interface LOTLayerGroup : NSObject

- (instancetype)initWithLayerJSON:(NSArray *)layersJSON
                       withBounds:(CGRect)bounds
                    withFramerate:(NSNumber *)framerate;

@property (nonatomic, readonly) NSArray <LOTLayer *> *layers;

- (LOTLayer *)layerModelForID:(NSNumber *)layerID;
- (LOTLayer *)layerForReferenceID:(NSString *)referenceID;

@end
