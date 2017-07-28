//
//  LOTPathAnimator.m
//  Pods
//
//  Created by brandon_withrow on 6/27/17.
//
//

#import "LOTPathAnimator.h"
#import "LOTPathInterpolator.h"
#import "LOTAnimatableShapeValue.h"

@implementation LOTPathAnimator {
  LOTShapePath *_pathConent;
  LOTPathInterpolator *_interpolator;
}

- (instancetype _Nonnull )initWithInputNode:(LOTAnimatorNode *_Nullable)inputNode
                                  shapePath:(LOTShapePath *_Nonnull)shapePath {
  self = [super initWithInputNode:inputNode];
  if (self) {
    _pathConent = shapePath;
    _interpolator = [[LOTPathInterpolator alloc] initWithKeyframes:_pathConent.shapePath.keyframeGroup.keyframes];
  }
  return self;
}

- (BOOL)needsUpdateForFrame:(NSNumber *)frame {
  return [_interpolator hasUpdateForFrame:frame];

}

- (void)performLocalUpdate {
  self.localPath = [_interpolator pathForFrame:self.currentFrame cacheLengths:self.pathShouldCacheLengths];
}

@end
