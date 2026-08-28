/* CoreAnimation - CATransaction.h

   Copyright (c) 2006-2025, Apple Inc.
   All rights reserved. */

#ifdef __OBJC__

#import "CABase.h"
#import <Foundation/NSObject.h>

/* Transactions are CoreAnimation's mechanism for batching multiple layer-
 * tree operations into atomic updates to the render tree. Every
 * modification to the layer tree requires a transaction to be part of.
 *
 * CoreAnimation supports two kinds of transactions, "explicit" transactions
 * and "implicit" transactions.
 *
 * Explicit transactions are where the programmer calls `[CATransaction
 * begin]' before modifying the layer tree, and `[CATransaction commit]'
 * afterwards.
 *
 * Implicit transactions are created automatically by CoreAnimation when the
 * layer tree is modified by a thread without an active transaction.
 * They are committed automatically when the thread's run-loop next
 * iterates. In some circumstances (i.e. no run-loop, or the run-loop
 * is blocked) it may be necessary to use explicit transactions to get
 * timely render tree updates. */

@class CAMediaTimingFunction;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

 
@interface CATransaction : NSObject

/* Begin a new transaction for the current thread; nests. */

+ (void)begin;

/* Commit all changes made during the current transaction. */

+ (void)commit;

/* Commits any extant implicit transaction. Will delay the actual commit
 * until any nested explicit transactions have completed. */

+ (void)flush;

/* Methods to lock and unlock the global lock. Layer methods automatically
 * obtain this while modifying shared state, but callers may need to lock
 * around multiple operations to ensure consistency. The lock is a
 * recursive spin-lock (i.e shouldn't be held for extended periods). */

+ (void)lock;
+ (void)unlock;

/* Accessors for the "animationDuration" per-thread transaction
 * property. Defines the default duration of animations added to
 * layers. Defaults to 1/4s. */

+ (CFTimeInterval)animationDuration;
+ (void)setAnimationDuration:(CFTimeInterval)dur;

/* Accessors for the "animationTimingFunction" per-thread transaction
 * property. The default value is nil, when set to a non-nil value any
 * animations added to layers will have this value set as their
 * "timingFunction" property. Added in Mac OS X 10.6. */

+ (nullable CAMediaTimingFunction *)animationTimingFunction;
+ (void)setAnimationTimingFunction:(nullable CAMediaTimingFunction *)function;

/* Accessors for the "disableActions" per-thread transaction property.
 * Defines whether or not the layer's -actionForKey: method is used to
 * find an action (aka. implicit animation) for each layer property
 * change. Defaults to NO, i.e. implicit animations enabled. */

+ (BOOL)disableActions;
+ (void)setDisableActions:(BOOL)flag;

/* Accessors for the "completionBlock" per-thread transaction property.
 * Once set to a non-nil value the block is guaranteed to be called (on
 * the main thread) as soon as all animations subsequently added by
 * this transaction group have completed (or been removed). If no
 * animations are added before the current transaction group is
 * committed (or the completion block is set to a different value), the
 * block will be invoked immediately. Added in Mac OS X 10.6. */

+ (nullable void (^)(void))completionBlock;
+ (void)setCompletionBlock:(nullable void (^)(void))block;

/* Associate arbitrary keyed-data with the current transaction (i.e.
 * with the current thread).
 *
 * Nested transactions have nested data scope, i.e. reading a key
 * searches for the innermost scope that has set it, setting a key
 * always sets it in the innermost scope.
 *
 * Currently supported transaction properties include:
 * "animationDuration", "animationTimingFunction", "completionBlock",
 * "disableActions". See method declarations above for descriptions of
 * each property.
 *
 * Attempting to set a property to a type other than its document type
 * has an undefined result. */

+ (nullable id)valueForKey:(NSString *)key;
+ (void)setValue:(nullable id)anObject forKey:(NSString *)key;

@end

/** Transaction property ids. **/

CA_EXTERN NSString * const kCATransactionAnimationDuration
     ;
CA_EXTERN NSString * const kCATransactionDisableActions
     ;
CA_EXTERN NSString * const kCATransactionAnimationTimingFunction
     ;
CA_EXTERN NSString * const kCATransactionCompletionBlock
     ;

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
