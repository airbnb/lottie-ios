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

/// Initializes the node with and optional intput node.
- (instancetype _Nonnull )initWithInputNode:(LOTAnimatorNode *_Nullable)inputNode;

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

- (void)logString:(NSString *_Nonnull)string;

@end

// TIME Is updated at the LAYER Level
// The LAYER has CONTAINER and updates its TIME.
// the CONTENTS of a CONTAINER can be other CONTAINERS, or ANIMATORS
// The CONATAINER also handles a subcoordinate XFORM and has a colleciton of RENDERERS
// The CONTAINER tells its RENDERERS and sub CONTAINERS to UPDATE TIME
// The RENDERERS tell their INPUT to update TIME and then asks for OUTPUTPATH
// The RENDERER then updates its SHAPELAYER

// RENDERS NODES - path input shapelayer output
// - FILL
// - STROKE
// - GRADIENT FILL
// - GRADIENT STROKE

// ANIMATOR NODES - Path input and path output
// - PATH
// - RECTANGLE
// - ELLIPSE
// - STAR

// - GROUP

// - TRIM PATH
// - MERGE PATH
// - TRANSFORM (Always last?)

/*

 Seems like we actually have three kinds of nodes
 Path nodes, which generate path data and merge with input data
 Render nodes which render out their input
 manipulators nodes, which all seem to operate differenctly.

 - Trimpath
  Affects all path nodes upstream. Needs complete context before it can perform its operation.
 
 - Mergepath
  Affects uses all path nodes upstream. Will disable all upstream rendernodes.
 
 - Repeater node
  Affects all path nodes upstream.
 
*/


