//
//  LOTAnimatorNode.m
//  Pods
//
//  Created by brandon_withrow on 6/27/17.
//
//

#import "LOTAnimatorNode.h"
#import "LOTHelpers.h"
#import "LOTValueInterpolator.h"

NSInteger indentation_level = 0;

@implementation LOTAnimatorNode


- (instancetype _Nonnull )initWithInputNode:(LOTAnimatorNode *_Nullable)inputNode
                                    keyName:(NSString *_Nullable)keyname {
  self = [super init];
  if (self) {
    _keyname = keyname;
    _inputNode = inputNode;
  }
  return self;
}

/// To be overwritten by subclass. Defaults to YES
- (BOOL)needsUpdateForFrame:(NSNumber *)frame {
  return YES;
}

/// The node checks if local update or if upstream update required. If upstream update outputs are rebuilt. If local update local update is performed. Returns no if no action
- (BOOL)updateWithFrame:(NSNumber *_Nonnull)frame {
  return [self updateWithFrame:frame withModifierBlock:NULL forceLocalUpdate:NO];
}

- (BOOL)updateWithFrame:(NSNumber *_Nonnull)frame
      withModifierBlock:(void (^_Nullable)(LOTAnimatorNode * _Nonnull inputNode))modifier
       forceLocalUpdate:(BOOL)forceUpdate{
  if ([_currentFrame isEqual:frame] && !forceUpdate) {
    return NO;
  }
  NSString *name = NSStringFromClass([self class]);
  if (ENABLE_DEBUG_LOGGING) [self logString:[NSString stringWithFormat:@"%@ %lu %@ Checking for update", name, (unsigned long)self.hash, self.keyname]];
  BOOL localUpdate = [self needsUpdateForFrame:frame] || forceUpdate;
  if (localUpdate && ENABLE_DEBUG_LOGGING) {
    [self logString:[NSString stringWithFormat:@"%@ %lu %@ Performing update", name, (unsigned long)self.hash, self.keyname]];
  }
  BOOL inputUpdated = [_inputNode updateWithFrame:frame
                                withModifierBlock:modifier
                                 forceLocalUpdate:forceUpdate];
  _currentFrame = frame;
  if (localUpdate) {
    [self performLocalUpdate];
    if (modifier) {
      modifier(self);
    }
  }
  
  if (inputUpdated || localUpdate) {
    [self rebuildOutputs];
  }
  return (inputUpdated || localUpdate);
}

- (void)forceSetCurrentFrame:(NSNumber *_Nonnull)frame {
  _currentFrame = frame;
}

- (void)logString:(NSString *)string {
  NSMutableString *logString = [NSMutableString string];
  [logString appendString:@"|"];
  for (int i = 0; i < indentation_level; i ++) {
    [logString appendString:@"  "];
  }
  [logString appendString:string];
  NSLog(@"%@", logString);
}

// TOBO BW Perf, make updates perform only when necessarry. Currently everything in a node is updated
/// Performs any local content update and updates self.localPath
- (void)performLocalUpdate {
  self.localPath = [[LOTBezierPath alloc] init];
}

/// Rebuilts outputs by adding localPath to inputNodes output path.
- (void)rebuildOutputs {
  if (self.inputNode) {
    self.outputPath = [self.inputNode.outputPath copy];
    [self.outputPath LOT_appendPath:self.localPath];
  } else {
    self.outputPath = self.localPath;
  }
}

- (void)setPathShouldCacheLengths:(BOOL)pathShouldCacheLengths {
  _pathShouldCacheLengths = pathShouldCacheLengths;
  self.inputNode.pathShouldCacheLengths = pathShouldCacheLengths;
}

/// Traverses children untill keypath is found and attempts to set the keypath to the value.
- (BOOL)setValue:(nonnull id)value
    forKeyAtPath:(nonnull NSString *)keypath
        forFrame:(nullable NSNumber *)frame {
  NSArray *components = [keypath componentsSeparatedByString:@"."];
  NSString *firstKey = components.firstObject;
  if ([firstKey isEqualToString:self.keyname] && components.count > 1) {
    NSString *nextPath = [keypath stringByReplacingCharactersInRange:NSMakeRange(0, firstKey.length + 1) withString:@""];
    return  [self setInterpolatorValue:value forKey:nextPath forFrame:frame];
  }
  return  [self.inputNode setValue:value forKeyAtPath:keypath forFrame:frame];
}

/// Sets the keyframe to the value, to be overwritten by subclasses
- (BOOL)setInterpolatorValue:(nonnull id)value
                      forKey:(nonnull NSString *)key
                    forFrame:(nullable NSNumber *)frame {
  LOTValueInterpolator *interpolator = self.valueInterpolators[key];
  if (interpolator) {
    return [interpolator setValue:value atFrame:frame];
  }
  return NO;
}

- (void)logHierarchyKeypathsWithParent:(NSString *)parent {
  NSString *keypath = self.keyname;
  if (parent && self.keyname) {
    keypath = [NSString stringWithFormat:@"%@.%@", parent, self.keyname];
  }
  if (keypath) {
    for (NSString *interpolator in self.valueInterpolators.allKeys) {
      [self logString:[NSString stringWithFormat:@"%@.%@", keypath, interpolator]];
    }
  }
  
  [self.inputNode logHierarchyKeypathsWithParent:parent];
}

@end
