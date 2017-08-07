//
//  LAMainView.h
//  lottie-ios
//
//  Created by brandon_withrow on 8/1/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LAMainView : NSView

- (void)setAnimationProgress:(CGFloat)progress;
- (void)playAnimation;
- (void)rewindAnimation;
- (void)toggleLoop;

-(void)openAnimationURL:(NSURL *)url;

@end
