//
//  LOTAnimatorNode.h
//  Pods
//
//  Created by brandon_withrow on 6/27/17.
//
//

#import <Foundation/Foundation.h>
#import "LOTPlatformCompat.h"
#import "LOTBezierPath.h"

extern NSInteger indentation_level;
@interface LOTAnimatorNode : NSObject

/// Initializes the node with and optional intput node and keyname.
- (instancetype _Nonnull )initWithInputNode:(LOTAnimatorNode *_Nullable)inputNode
                                    keyName:(NSString *_Nullable)keyname;

/// A dictionary of the value interpolators this node controls
@property (nonatomic, readonly, strong) NSDictionary * _Nullable valueInterpolators;

/// The keyname of the node. Used for dynamically setting keyframe data.
@property (nonatomic, readonly, strong) NSString * _Nullable keyname;

/// The current time in frames
@property (nonatomic, readonly, strong) NSNumber * _Nullable currentFrame;
/// The upstream animator node
@property (nonatomic, readonly, strong) LOTAnimatorNode * _Nullable inputNode;

/// This nodes path in local object space
@property (nonatomic, strong) LOTBezierPath * _Nonnull localPath;
/// The sum of all paths in the tree including this node
@property (nonatomic, strong) LOTBezierPath * _Nonnull outputPath;

/// Returns true if this node needs to update its contents for the given frame. To be overwritten by subclasses.
- (BOOL)needsUpdateForFrame:(NSNumber *_Nonnull)frame;

/// Sets the current frame and performs any updates. Returns true if any updates were performed, locally or upstream.
- (BOOL)updateWithFrame:(NSNumber *_Nonnull)frame;
- (BOOL)updateWithFrame:(NSNumber *_Nonnull)frame
      withModifierBlock:(void (^_Nullable)(LOTAnimatorNode * _Nonnull inputNode))modifier
       forceLocalUpdate:(BOOL)forceUpdate;

- (void)forceSetCurrentFrame:(NSNumber *_Nonnull)frame;

@property (nonatomic, assign) BOOL pathShouldCacheLengths;
/// Update the local content for the frame.
- (void)performLocalUpdate;

/// Rebuild all outputs for the node. This is called after upstream updates have been performed.
- (void)rebuildOutputs;

/// Traverses children untill keypath is found and attempts to set the keypath to the value.
- (BOOL)setValue:(nonnull id)value
    forKeyAtPath:(nonnull NSString *)keypath
        forFrame:(nullable NSNumber *)frame;

/// Sets the keyframe to the value, to be overwritten by subclasses
- (BOOL)setInterpolatorValue:(nonnull id)value
                      forKey:(nonnull NSString *)key
                    forFrame:(nullable NSNumber *)frame;

- (void)logString:(NSString *_Nonnull)string;

- (void)logHierarchyKeypathsWithParent:(NSString * _Nullable)parent;

@end
