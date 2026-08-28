/* CoreAnimation - CATextLayer.h

   Copyright (c) 2006-2025, Apple Inc.
   All rights reserved. */

#ifdef __OBJC__

#import "CALayer.h"

/* The text layer provides simple text layout and rendering of plain
 * or attributed strings. The first line is aligned to the top of the
 * layer. */

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NSString * CATextLayerTruncationMode NS_TYPED_ENUM  ;
typedef NSString * CATextLayerAlignmentMode NS_TYPED_ENUM  ;

 
@interface CATextLayer : CALayer
{
@private
  struct CATextLayerPrivate *_state;
}

/* The text to be rendered, should be either an NSString or an
 * NSAttributedString. Defaults to nil. */

@property(nullable, copy) id string;

/* The font to use, currently may be either a CTFontRef (toll-free
 * bridged from NSFont or UIFont), a CGFontRef, or a string naming the font.
 * Defaults to the Helvetica font. Only used when the `string' property
 * is not an NSAttributedString. */

@property(nullable) CFTypeRef font;

/* The font size. Defaults to 36. Only used when the `string' property
 * is not an NSAttributedString. Animatable (Mac OS X 10.6 and later.) */

@property CGFloat fontSize;

/* The color object used to draw the text. Defaults to opaque white.
 * Only used when the `string' property is not an NSAttributedString.
 * Animatable (Mac OS X 10.6 and later.) */

@property(nullable) CGColorRef foregroundColor;

/* When true the string is wrapped to fit within the layer bounds.
 * Defaults to NO.*/

@property(getter=isWrapped) BOOL wrapped;

/* Describes how the string is truncated to fit within the layer
 * bounds. The possible options are `none', `start', `middle' and
 * `end'. Defaults to `none'. */

@property(copy) CATextLayerTruncationMode truncationMode;

/* Describes how individual lines of text are aligned within the layer
 * bounds. The possible options are `natural', `left', `right',
 * `center' and `justified'. Defaults to `natural'. */

@property(copy) CATextLayerAlignmentMode alignmentMode;

/* Sets allowsFontSubpixelQuantization parameter of CGContextRef
 * passed to the -drawInContext: method. Defaults to NO. */

@property BOOL allowsFontSubpixelQuantization;

@end

/* Truncation modes. */

CA_EXTERN CATextLayerTruncationMode const kCATruncationNone
     ;
CA_EXTERN CATextLayerTruncationMode const kCATruncationStart
     ;
CA_EXTERN CATextLayerTruncationMode const kCATruncationEnd
     ;
CA_EXTERN CATextLayerTruncationMode const kCATruncationMiddle
     ;

/* Alignment modes. */

CA_EXTERN CATextLayerAlignmentMode const kCAAlignmentNatural
     ;
CA_EXTERN CATextLayerAlignmentMode const kCAAlignmentLeft
     ;
CA_EXTERN CATextLayerAlignmentMode const kCAAlignmentRight
     ;
CA_EXTERN CATextLayerAlignmentMode const kCAAlignmentCenter
     ;
CA_EXTERN CATextLayerAlignmentMode const kCAAlignmentJustified
     ;

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
