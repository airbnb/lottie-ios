//
//  NSValueTransformer+MTLPredefinedTransformerAdditions.h
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-27.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTLTransformerErrorHandling.h"

/// The name for a value transformer that converts strings into URLs and back.
extern NSString * const MTLURLValueTransformerName;

/// Ensure an NSNumber is backed by __NSCFBoolean/CFBooleanRef
///
/// NSJSONSerialization, and likely other serialization libraries, ordinarily
/// serialize NSNumbers as numbers, and thus booleans would be serialized as
/// 0/1. The exception is when the NSNumber is backed by __NSCFBoolean, which,
/// though very much an implementation detail, is detected and serialized as a
/// proper boolean.
extern NSString * const MTLBooleanValueTransformerName;

@interface NSValueTransformer (MTLPredefinedTransformerAdditions)

/// An optionally reversible transformer which applies the given transformer to
/// each element of an array.
///
/// transformer - The transformer to apply to each element. If the transformer
///               is reversible, the transformer returned by this method will be
///               reversible. This argument must not be nil.
///
/// Returns a transformer which applies a transformation to each element of an
/// array.
+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_arrayMappingTransformerWithTransformer:(NSValueTransformer *)transformer;

/// A reversible value transformer to transform between the keys and objects of a
/// dictionary.
///
/// dictionary          - The dictionary whose keys and values should be
///                       transformed between. This argument must not be nil.
/// defaultValue        - The result to fall back to, in case no key matching the
///                       input value was found during a forward transformation.
/// reverseDefaultValue - The result to fall back to, in case no value matching
///                       the input value was found during a reverse
///                       transformation.
///
/// Can for example be used for transforming between enum values and their string
/// representation.
///
///   NSValueTransformer *valueTransformer = [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
///     @"foo": @(EnumDataTypeFoo),
///     @"bar": @(EnumDataTypeBar),
///   } defaultValue: @(EnumDataTypeUndefined) reverseDefaultValue: @"undefined"];
///
/// Returns a transformer which will map from keys to objects for forward
/// transformations, and from objects to keys for reverse transformations.
+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_valueMappingTransformerWithDictionary:(NSDictionary *)dictionary defaultValue:(id)defaultValue reverseDefaultValue:(id)reverseDefaultValue;

/// Returns a value transformer created by calling
/// `+mtl_valueMappingTransformerWithDictionary:defaultValue:reverseDefaultValue:`
/// with a default value of `nil` and a reverse default value of `nil`.
+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_valueMappingTransformerWithDictionary:(NSDictionary *)dictionary;

/// A value transformer that errors if the transformed value are not of the given
/// class.
///
/// class - The expected class. This argument must not be nil.
///
/// Returns a transformer which will return an error if the transformed in value
/// is not a member of class. Otherwise, the value is simply passed through.
+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_validatingTransformerForClass:(Class)modelClass;

+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_JSONDictionaryTransformerWithModelClass:(Class)modelClass __attribute__((deprecated("Replaced by +[MTLJSONAdapter dictionaryTransformerWithModelClass:]")));

+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_JSONArrayTransformerWithModelClass:(Class)modelClass __attribute__((deprecated("Replaced by +[MTLJSONAdapter arrayTransformerWithModelClass:]")));

@end
