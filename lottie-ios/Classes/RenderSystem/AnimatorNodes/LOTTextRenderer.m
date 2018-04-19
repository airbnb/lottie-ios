//
//  LOTTextAnimator.m
//  Lottie
//
//  Created by Adam Tierney on 4/19/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import "LOTTextRenderer.h"
#import "LOTNumberInterpolator.h"
#import "LOTColorInterpolator.h"
#import "LOTTransformInterpolator.h"

#import "LOTShapeFill.h"
#import "LOTShapeStroke.h"
#import "LOTCharacter.h"
#import "LOTShapeGroup.h"
#import "LOTRenderGroup.h"
#import "LOTShapeTransform.h"
#import "LOTShapeGroup.h"

@implementation LOTTextRenderer {
  LOTText *_text;
  LOTAnimatorNode *_rootNode;
  BOOL _rootNodeHasUpdate;
  LOTBezierPath *_outputPath;
  LOTBezierPath *_localPath;
  NSArray *_characterNodes;
}

- (LOTBezierPath *)localPath {
  return _localPath;
}

- (LOTBezierPath *)outputPath {
  return _outputPath;
}

- (instancetype _Nonnull)initWithInputNode:(LOTAnimatorNode *_Nullable)inputNode
                                  document:(LOTText *_Nonnull)text {

  // FIXME: proper name
  NSString *name = text.keyframes.firstObject.text;
  if (!name) name = @"footext";
  self = [super initWithInputNode:inputNode keyName:name];
  if (self) {
    _text = text;
    [self buildContents];
  }
  return self;
}

- (void)buildContents {

  // get path from each letter, translate it by the current tracking, add it in
  // FIXME: proper text keyframes
  LOTTextDocumentKeyframe *frame = _text.keyframes.firstObject;
  CGFloat preceedingCharactersWidths = 0;
  CGFloat fontScale = frame.fontSize.floatValue / 100;
  CGFloat tracking = frame.tracking.floatValue;
  NSMutableArray *children = [NSMutableArray array];
  if (frame) {
    for (int i=0; i < frame.characters.count; i++) {

      LOTCharacter *character = frame.characters[i];

      // each character is positioned with a relative horizontal transform modified by the width
      // tracking interpolator

      CGFloat characterWidth = character.width.floatValue * fontScale;

      LOTKeyframeGroup *trackingKeyframes;
      if (_text.animations.tracking) {
        trackingKeyframes = [_text.animations.tracking copy];
      } else {
        LOTKeyframe *defaultTracking = [[LOTKeyframe alloc] initWithValue:frame.tracking];
        trackingKeyframes = [[LOTKeyframeGroup alloc] initWithKeyframes:@[defaultTracking]];
      }

      [trackingKeyframes remapKeyframesWithBlock:^CGFloat(CGFloat inValue) {
        // all characters width accumulated + preceeding chars count * tracking
        return preceedingCharactersWidths + ((tracking + inValue) * i);
      }];

      for (LOTKeyframe *frame in trackingKeyframes.keyframes) {
        [frame formPointFromFloatValue:0];
      }

      LOTKeyframe *scale = [[LOTKeyframe alloc] initWithSizeValue:CGSizeMake(fontScale, fontScale)];
      LOTKeyframeGroup *scaleGroup = [[LOTKeyframeGroup alloc] initWithKeyframes:@[scale]];

      LOTShapeTransform *transformNode = [[LOTShapeTransform alloc] initWithPositionKeyframes:trackingKeyframes
                                                                               scaleKeyframes:scaleGroup];

      //FIXME: real text keyframes
      LOTKeyframe *colorFrame = [[LOTKeyframe alloc] initWithColorValue:frame.strokeColor];
      LOTKeyframeGroup *colorGrp = [[LOTKeyframeGroup alloc] initWithKeyframes:@[colorFrame]];
      NSNumber * v = [[NSNumber alloc] initWithFloat:frame.strokeWidth.floatValue / fontScale];
      LOTKeyframe *strokeWidthFrame = [[LOTKeyframe alloc] initWithValue:v];
      LOTKeyframeGroup *strokeGrp = [[LOTKeyframeGroup alloc] initWithKeyframes:@[strokeWidthFrame]];
      //
      LOTShapeStroke *strokeNode = [[LOTShapeStroke alloc] initWithKeyname:character.characterString
                                                                colorFrames:colorGrp
                                                                widthFrames:strokeGrp// _text.animations.strokeWidth
                                                              opacityFrames:[[LOTKeyframeGroup alloc] initWithData:@1]];

      NSArray *strokeItems = [character.shapes.items arrayByAddingObject:strokeNode];

      LOTShapeGroup *strokeGroup = [[LOTShapeGroup alloc] initWithKeyname:character.characterString
                                                                     shapes:strokeItems];

      //FIXME: real text keyframes
      LOTKeyframeGroup *fillGrp;
      if (!_text.animations.fillColor) {
        LOTKeyframe *fillColor = [[LOTKeyframe alloc] initWithColorValue:frame.fontColor];
        fillGrp = [[LOTKeyframeGroup alloc] initWithKeyframes:@[fillColor]];
      } else {
        fillGrp = _text.animations.fillColor;
      }
      //

      LOTShapeFill *fillNode = [[LOTShapeFill alloc] initWithKeyName:character.characterString
                                                      colorKeyframes:fillGrp//_text.animations.fillColor
                                                    opacityKeyframes:[[LOTKeyframeGroup alloc] initWithData:@1]];

      NSArray *fillItems = [character.shapes.items arrayByAddingObject:fillNode];

      LOTShapeGroup *fillGroup = [[LOTShapeGroup alloc] initWithKeyname:character.characterString
                                                                  shapes:fillItems];

      NSArray *characterGroups;
      // these are "fifo" because the render group always inserts at the 0 index so [stroke, fill]
      // renders as fill, stroke in the layer heirarchy
      if (frame.strokeOverfill) {
        characterGroups = @[strokeGroup, fillGroup];
      } else {
        characterGroups = @[fillGroup, strokeGroup];
      }

      NSArray *items = [characterGroups arrayByAddingObject:transformNode];

      LOTRenderGroup *characterGroup = [[LOTRenderGroup alloc] initWithInputNode:children.lastObject
                                                                        contents:items
                                                                         keyname:character.characterString];

      [self.outputLayer insertSublayer:characterGroup.containerLayer atIndex:0];
      [children addObject:characterGroup];

      // increment
      preceedingCharactersWidths += characterWidth;
    }

    _characterNodes = children;
    _rootNode = children.lastObject;
  }
}

- (NSDictionary *)valueInterpolators {
  // TODO:
  return @{};
}

// TODO: can this all be accomplished by a render group? can this be striped down?
- (BOOL)needsUpdateForFrame:(NSNumber *)frame {
  // TODO: make text keyframe interpolator
  // check if keyframes need update
  return _rootNodeHasUpdate;
}

- (void)performLocalUpdate {
  _localPath = [_rootNode.outputPath copy];
}

- (void)rebuildOutputs {
  if (self.inputNode) {
    _outputPath = [self.inputNode.outputPath copy];
    [_outputPath LOT_appendPath:self.localPath];
  } else {
    _outputPath = self.localPath;
  }
  _outputPath = _localPath;
}

- (BOOL)updateWithFrame:(NSNumber *)frame withModifierBlock:(void (^ _Nullable)(LOTAnimatorNode * _Nonnull))modifier forceLocalUpdate:(BOOL)forceUpdate {
  indentation_level = indentation_level + 1;
  _rootNodeHasUpdate = [_rootNode updateWithFrame:frame withModifierBlock:modifier forceLocalUpdate:forceUpdate];
  indentation_level = indentation_level - 1;
  BOOL update = [super updateWithFrame:frame withModifierBlock:modifier forceLocalUpdate:forceUpdate];
  return update;
}

- (NSDictionary *)actionsForRenderLayer {
  // TODO:
  return @{
           @"strokeColor": [NSNull null],
           @"lineWidth": [NSNull null],
           @"opacity" : [NSNull null]
           };
}

@end
