/* CoreAnimation - CATiledLayer.h

   Copyright (c) 2006-2025, Apple Inc.
   All rights reserved. */

/* This is a subclass of CALayer providing a way to asynchronously
 * provide tiles of the layer's content, potentially cached at multiple
 * levels of detail.
 *
 * As more data is required by the renderer, the layer's
 * -drawInContext: method is called on one or more background threads
 * to supply the drawing operations to fill in one tile of data. The
 * clip bounds and CTM of the drawing context can be used to determine
 * the bounds and resolution of the tile being requested.
 *
 * Regions of the layer may be invalidated using the usual
 * -setNeedsDisplayInRect: method. However update will be asynchronous,
 * i.e. the next display update will most likely not contain the
 * changes, but a future update will.
 *
 * Note: do not attempt to directly modify the `contents' property of
 * an CATiledLayer object - doing so will effectively turn it into a
 * regular CALayer. */

#ifdef __OBJC__

#import "CALayer.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

 
@interface CATiledLayer : CALayer

/* The time in seconds that newly added images take to "fade-in" to the
 * rendered representation of the tiled layer. The default implementation
 * returns 0.25 seconds. */

+ (CFTimeInterval)fadeDuration;

/* The number of levels of detail maintained by this layer. Defaults to
 * one. Each LOD is half the resolution of the previous level. If too
 * many levels are specified for the current size of the layer, then
 * the number of levels is clamped to the maximum value (the bottom
 * most LOD must contain at least a single pixel in each dimension). */

@property size_t levelsOfDetail;

/* The number of magnified levels of detail for this layer. Defaults to
 * zero. Each previous level of detail is twice the resolution of the
 * later. E.g. specifying 'levelsOfDetailBias' of two means that the
 * layer devotes two of its specified levels of detail to
 * magnification, i.e. 2x and 4x. */

@property size_t levelsOfDetailBias;

/* The maximum size of each tile used to create the layer's content.
 * Defaults to (256, 256). Note that there is a maximum tile size, and
 * requests for tiles larger than that limit will cause a suitable
 * value to be substituted. */

@property CGSize tileSize;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
