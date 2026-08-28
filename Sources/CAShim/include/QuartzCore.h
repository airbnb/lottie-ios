/* QuartzCore.h

   Copyright (c) 2004-2025, Apple Inc.
   All rights reserved. */

#ifndef QUARTZCORE_H
#define QUARTZCORE_H

#if __has_include(<QuartzCore/CoreImage.h>) && !__has_feature(modules)
#include "CoreImage.h"
#endif

#if __has_include(<QuartzCore/CoreVideo.h>) && !__has_feature(modules)
#include "CoreVideo.h"
#endif

#include "CoreAnimation.h"

#endif /* QUARTZCORE_H */

#import "LottieWatchShim.h"
