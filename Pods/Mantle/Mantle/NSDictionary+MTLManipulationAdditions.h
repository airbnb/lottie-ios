//
//  NSDictionary+MTLManipulationAdditions.h
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-24.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MTLManipulationAdditions)

/// Merges the keys and values from the given dictionary into the receiver. If
/// both the receiver and `dictionary` have a given key, the value from
/// `dictionary` is used.
///
/// Returns a new dictionary containing the entries of the receiver combined with
/// those of `dictionary`.
- (NSDictionary *)mtl_dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary;

/// Creates a new dictionary with all the entries for the given keys removed from
/// the receiver.
- (NSDictionary *)mtl_dictionaryByRemovingValuesForKeys:(NSArray *)keys;

@end

@interface NSDictionary (MTLManipulationAdditions_Deprecated)

- (NSDictionary *)mtl_dictionaryByRemovingEntriesWithKeys:(NSSet *)keys __attribute__((deprecated("Replaced by -mtl_dictionaryByRemovingValuesForKeys:")));

@end
