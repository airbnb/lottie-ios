//
//  NSDictionary+MTLJSONKeyPath.h
//  Mantle
//
//  Created by Robert Böhnke on 19/03/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MTLJSONKeyPath)

/// Looks up the value of a key path in the receiver.
///
/// JSONKeyPath - The key path that should be resolved. Every element along this
///               key path needs to be an instance of NSDictionary for the
///               resolving to be successful.
/// success     - If not NULL, this will be set to a boolean indicating whether
///               the key path was resolved successfully.
/// error       - If not NULL, this may be set to an error that occurs during
///               resolving the value.
///
/// Returns the value for the key path which may be nil. Clients should inspect
/// the success parameter to decide how to proceed with the result.
- (id)mtl_valueForJSONKeyPath:(NSString *)JSONKeyPath success:(BOOL *)success error:(NSError **)error;

@end
