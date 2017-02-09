//
// Created by Oleksii Pavlovskyi on 2/2/17.
// Copyright (c) 2017 Airbnb. All rights reserved.
//

#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#import "CADisplayLink.h"
#import <CoreVideo/CoreVideo.h>

@interface CADisplayLink()

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

- (void)tick;

@end

CVReturn displayLinkCallback(CVDisplayLinkRef displayLink,
        const CVTimeStamp *_, const CVTimeStamp *__,
        CVOptionFlags ___, CVOptionFlags *____,
        void *context) {
    @autoreleasepool {
        CADisplayLink *self = (__bridge CADisplayLink *)context;
        [self tick];
    }
    return kCVReturnSuccess;
}

@implementation CADisplayLink {
    CVDisplayLinkRef _displayLink;
}

+ (CADisplayLink *)displayLinkWithTarget:(id)target selector:(SEL)sel {
    CADisplayLink *displayLink = [self new];
    displayLink.target = target;
    displayLink.action = sel;
    return displayLink;
}

- (void)addToRunLoop:(NSRunLoop *)runloop forMode:(NSRunLoopMode)mode {
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(_displayLink, displayLinkCallback, (__bridge void *)self);
    CVDisplayLinkStart(_displayLink);
}

- (void)invalidate {
    if (_displayLink)
        CVDisplayLinkStop(_displayLink);
}

- (void)dealloc {
    if (_displayLink)
        CVDisplayLinkRelease(_displayLink);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)tick {
    if (self.action && [self.target respondsToSelector:self.action])
        [self.target performSelector:self.action];
}
#pragma clang diagnostic pop

@end

#endif
