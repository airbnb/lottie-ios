/* CoreAnimation - CAFrameRateRange.h

   Copyright (c) 2020-2025, Apple Inc.
   All rights reserved. */

#ifndef CAFRAMERATERANGE_H
#define CAFRAMERATERANGE_H

#include "CABase.h"
#include <stdbool.h>

struct CAFrameRateRange {
  float minimum;
  float maximum;
  float preferred CF_REFINED_FOR_SWIFT;
}  ;

typedef struct CAFrameRateRange CAFrameRateRange
   ;

CA_EXTERN_C_BEGIN

CA_EXTERN const CAFrameRateRange CAFrameRateRangeDefault
   
  CF_SWIFT_NAME(CAFrameRateRange.default);

CA_EXTERN CAFrameRateRange CAFrameRateRangeMake(float minimum,
                                                float maximum,
                                                float preferred)
   
  CF_SWIFT_UNAVAILABLE("Use CAFrameRateRange.init(minimum:maximum:preferred) instead");

CA_EXTERN bool CAFrameRateRangeIsEqualToRange(CAFrameRateRange range,
                                              CAFrameRateRange other)
   
  CF_REFINED_FOR_SWIFT;

CA_EXTERN_C_END

#endif /* CAFRAMERATERANGE_H */
