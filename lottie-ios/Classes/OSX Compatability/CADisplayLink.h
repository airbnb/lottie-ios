//
// Created by Oleksii Pavlovskyi on 2/2/17.
// Copyright (c) 2017 Airbnb. All rights reserved.
//

#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#import <Foundation/Foundation.h>

@interface CADisplayLink : NSObject

+ (CADisplayLink *)displayLinkWithTarget:(id)target selector:(SEL)sel;
- (void)addToRunLoop:(NSRunLoop *)runloop forMode:(NSRunLoopMode)mode;
- (void)invalidate;

@end
#endif
