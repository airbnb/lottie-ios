//
//  MTLModel.h
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-11.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Defines a property's storage behavior, which affects how it will be copied,
/// compared, and persisted.
///
/// MTLPropertyStorageNone       - This property is not included in -description,
///                                -hash, or anything else.
/// MTLPropertyStorageTransitory - This property is included in one-off
///                                operations like -copy and -dictionaryValue but
///                                does not affect -isEqual: or -hash.
///                                It may disappear at any time.
/// MTLPropertyStoragePermanent  - The property is included in serialization
///                                (like `NSCoding`) and equality, since it can
///                                be expected to stick around.
typedef enum : NSUInteger {
    MTLPropertyStorageNone,
    MTLPropertyStorageTransitory,
    MTLPropertyStoragePermanent,
} MTLPropertyStorage;

/// This protocol defines the minimal interface that classes need to implement to
/// interact with Mantle adapters.
///
/// It is intended for scenarios where inheriting from MTLModel is not feasible.
/// However, clients are encouraged to subclass the MTLModel class if they can.
///
/// Clients that wish to implement their own adapters should target classes
/// conforming to this protocol rather than subclasses of MTLModel to ensure
/// maximum compatibility.
@protocol MTLModel <NSObject, NSCopying>

/// Initializes a new instance of the receiver using key-value coding, setting
/// the keys and values in the given dictionary.
///
/// dictionaryValue - Property keys and values to set on the instance. Any NSNull
///                   values will be converted to nil before being used. KVC
///                   validation methods will automatically be invoked for all of
///                   the properties given.
/// error           - If not NULL, this may be set to any error that occurs
///                   (like a KVC validation error).
///
/// Returns an initialized model object, or nil if validation failed.
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error;

/// A dictionary representing the properties of the receiver.
///
/// Combines the values corresponding to all +propertyKeys into a dictionary,
/// with any nil values represented by NSNull.
///
/// This property must never be nil.
@property (nonatomic, copy, readonly) NSDictionary *dictionaryValue;

/// Initializes the receiver using key-value coding, setting the keys and values
/// in the given dictionary.
///
/// Subclass implementations may override this method, calling the super
/// implementation, in order to perform further processing and initialization
/// after deserialization.
///
/// dictionaryValue - Property keys and values to set on the receiver. Any NSNull
///                   values will be converted to nil before being used. KVC
///                   validation methods will automatically be invoked for all of
///                   the properties given. If nil, this method is equivalent to
///                   -init.
/// error           - If not NULL, this may be set to any error that occurs
///                   (like a KVC validation error).
///
/// Returns an initialized model object, or nil if validation failed.
- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error;

/// Merges the value of the given key on the receiver with the value of the same
/// key from the given model object, giving precedence to the other model object.
- (void)mergeValueForKey:(NSString *)key fromModel:(id<MTLModel>)model;

/// Returns the keys for all @property declarations, except for `readonly`
/// properties without ivars, or properties on MTLModel itself.
+ (NSSet *)propertyKeys;

/// Validates the model.
///
/// error - If not NULL, this may be set to any error that occurs during
///         validation
///
/// Returns YES if the model is valid, or NO if the validation failed.
- (BOOL)validate:(NSError **)error;

@end

/// An abstract base class for model objects, using reflection to provide
/// sensible default behaviors.
///
/// The default implementations of <NSCopying>, -hash, and -isEqual: make use of
/// the +propertyKeys method.
@interface MTLModel : NSObject <MTLModel>

/// Initializes the receiver using key-value coding, setting the keys and values
/// in the given dictionary.
///
/// dictionaryValue - Property keys and values to set on the receiver. Any NSNull
///                   values will be converted to nil before being used. KVC
///                   validation methods will automatically be invoked for all of
///                   the properties given. If nil, this method is equivalent to
///                   -init.
/// error           - If not NULL, this may be set to any error that occurs
///                   (like a KVC validation error).
///
/// Returns an initialized model object, or nil if validation failed.
- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error;

/// Initializes the receiver with default values.
///
/// This is the designated initializer for this class.
- (instancetype)init;

/// By default, this method looks for a `-merge<Key>FromModel:` method on the
/// receiver, and invokes it if found. If not found, and `model` is not nil, the
/// value for the given key is taken from `model`.
- (void)mergeValueForKey:(NSString *)key fromModel:(id<MTLModel>)model;

/// Merges the values of the given model object into the receiver, using
/// -mergeValueForKey:fromModel: for each key in +propertyKeys.
///
/// `model` must be an instance of the receiver's class or a subclass thereof.
- (void)mergeValuesForKeysFromModel:(id<MTLModel>)model;

/// The storage behavior of a given key.
///
/// The default implementation returns MTLPropertyStorageNone for properties that
/// are readonly and not backed by an instance variable and
/// MTLPropertyStoragePermanent otherwise.
///
/// Subclasses can use this method to prevent MTLModel from resolving circular
/// references by returning MTLPropertyStorageTransitory.
///
/// Returns the storage behavior for a given key on the receiver.
+ (MTLPropertyStorage)storageBehaviorForPropertyWithKey:(NSString *)propertyKey;

/// Compares the receiver with another object for equality.
///
/// The default implementation is equivalent to comparing all properties of both
/// models for which +storageBehaviorForPropertyWithKey: returns
/// MTLPropertyStoragePermanent.
///
/// Returns YES if the two models are considered equal, NO otherwise.
- (BOOL)isEqual:(id)object;

/// A string that describes the contents of the receiver.
///
/// The default implementation is based on the receiver's class and all its
/// properties for which +storageBehaviorForPropertyWithKey: returns
/// MTLPropertyStoragePermanent.
- (NSString *)description;

@end

/// Implements validation logic for MTLModel.
@interface MTLModel (Validation)

/// Validates the model.
///
/// The default implementation simply invokes -validateValue:forKey:error: with
/// all +propertyKeys and their current value. If -validateValue:forKey:error:
/// returns a new value, the property is set to that new value.
///
/// error - If not NULL, this may be set to any error that occurs during
///         validation
///
/// Returns YES if the model is valid, or NO if the validation failed.
- (BOOL)validate:(NSError **)error;

@end
