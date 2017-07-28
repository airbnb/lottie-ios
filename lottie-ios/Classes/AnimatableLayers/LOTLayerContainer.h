//
//  LOTLayerContainer.h
//  Lottie
//
//  Created by brandon_withrow on 7/18/17.
//  Copyright © 2017 Airbnb. All rights reserved.
//

#import "LOTPlatformCompat.h"
#import "LOTLayer.h"
#import "LOTLayerGroup.h"

@interface LOTLayerContainer : CALayer

- (instancetype)initWithModel:(LOTLayer *)layer
                 inLayerGroup:(LOTLayerGroup *)layerGroup;

@property (nonatomic) NSNumber *currentFrame;
@property (nonatomic, assign) CGRect viewportBounds;
@property (nonatomic, readonly) CALayer *wrapperLayer;
- (void)displayWithFrame:(NSNumber *)frame;

@end
