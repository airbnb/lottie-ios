//
//  LOTText.m
//  Lottie
//
//  Created by Adam Tierney on 4/18/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import "LOTText.h"
#import "LOTModels.h"

@implementation LOTText

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary {
  self = [super init];
  if (self) {
    [self _mapFromJSON:jsonDictionary];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary {

  // Animations:
  // This is an array, but we're only concerned with the first item. This cue is taken from the
  // Android implementation but may have a better reason we can note here:
  NSDictionary *textAnimationsJSON = [jsonDictionary[@"a"] firstObject];
  _animations = [[LOTTextAnimations alloc] initWithJSON:textAnimationsJSON];

  // Documents
  NSDictionary *documentJSON = jsonDictionary[@"d"];
  NSArray *keyframesJSON = documentJSON[@"k"];
  _propertyFrames = [[LOTKeyframeGroup alloc] initWithData:keyframesJSON];
}

- (NSArray<LOTTextFrame*> *)textFramesFromKeyframes {
  NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:_propertyFrames.keyframes.count];
  for (LOTKeyframe *frame in _propertyFrames.keyframes) {
    LOTTextFrame *textFrame = [[LOTTextFrame alloc] initWithProperties:frame.textProperties
                                                         andAnimations:_animations
                                                             fromGroup:_propertyFrames];
    [arr addObject:textFrame];
  }
  return arr;
}

@end

@implementation LOTTextFrame {
  CGFloat _fontScale;
  LOTKeyframeGroup *_strokeWidthKeyframes;
  LOTKeyframeGroup *_strokeColorKeyframes;
  LOTKeyframeGroup *_fillColorKeyframes;
  LOTKeyframeGroup *_opacityKeyframes;
}

- (instancetype)initWithProperties:(LOTTextProperties*)properties
                     andAnimations:(LOTTextAnimations*)animations
                         fromGroup:(LOTKeyframeGroup*)group {
  self = [super init];
  if (self) {
    _properties = properties;
    _animations = animations;
    _textFrameGroup = group;
    [self sharedInit];
    [self buildAnimationKeyframeGroups];
    [self buildShapes];
  }
  return self;
}

- (void)sharedInit {
  _fontScale = _properties.fontSize.floatValue / 100;
}

- (void)buildAnimationKeyframeGroups {
  // stroke width, unscaled
  if (_animations.strokeWidth) {
    _strokeWidthKeyframes = _animations.strokeWidth;
    CGFloat fontScale = _fontScale;
    [_strokeWidthKeyframes remapKeyframesWithBlock:^CGFloat(CGFloat inValue) {
      return inValue / fontScale;
    }];
  } else if (_properties.strokeWidth) {
    NSNumber *normalizedStrokeWidth = [[NSNumber alloc] initWithFloat:_properties.strokeWidth.floatValue / _fontScale];
    LOTKeyframe *strokeWidthKeyframe = [[LOTKeyframe alloc] initWithValue:normalizedStrokeWidth];
    _strokeWidthKeyframes = [[LOTKeyframeGroup alloc] initWithKeyframes:@[strokeWidthKeyframe]];
  } else {
    _strokeWidthKeyframes = nil;
  }

  if (_animations.strokeColor) {
    _strokeColorKeyframes = _animations.strokeColor;
  } else if (_properties.strokeColor) {
    LOTKeyframe *colorKeyframe = [[LOTKeyframe alloc] initWithColorValue:_properties.strokeColor];
    _strokeColorKeyframes = [[LOTKeyframeGroup alloc] initWithKeyframes:@[colorKeyframe]];
  } else {
    _strokeColorKeyframes = nil;
  }

  if (_animations.fillColor) {
    _fillColorKeyframes = _animations.fillColor;
  } else if (_properties.fontColor) {
    LOTKeyframe *colorKeyframe = [[LOTKeyframe alloc] initWithColorValue:_properties.fontColor];
    _fillColorKeyframes = [[LOTKeyframeGroup alloc] initWithKeyframes:@[colorKeyframe]];
  } else {
    _fillColorKeyframes = nil;
  }

  // layer frames are either visisble or not visible, iterate through the text frames and set this
  // frame to be visible if equal else invisible:
  NSMutableArray<LOTKeyframe*> *opacityFrames = [[NSMutableArray alloc] initWithCapacity:_textFrameGroup.keyframes.count];
  for (LOTKeyframe *frame in _textFrameGroup.keyframes) {
    LOTKeyframe *opacityFrame;
    if ([frame.textProperties isEqual:_properties]) {
      opacityFrame = [[LOTKeyframe alloc] initWithValue:@1 forTime:frame.keyframeTime];
    } else {
      opacityFrame = [[LOTKeyframe alloc] initWithValue:@0 forTime:frame.keyframeTime];
    }
    [opacityFrames addObject:opacityFrame];
  }
  _opacityKeyframes = [[LOTKeyframeGroup alloc] initWithKeyframes:opacityFrames];
}

/// parse character shapes for this frame into animation node models
- (void)buildShapes {
  NSUInteger charCount = _properties.characters.count;
  NSMutableArray *groupsArray = [[NSMutableArray alloc] initWithCapacity:charCount];

  CGFloat preceedingCharactersWidths = 0;
  CGFloat tracking = _properties.tracking.floatValue;

  // render each character in the frame
  for (int i=0; i < charCount; i++) {
    LOTCharacter *character = _properties.characters[i];

    // each character is positioned with a relative horizontal transform modified by the width
    // tracking interpolator

    CGFloat characterWidth = character.width.floatValue * _fontScale;

    LOTKeyframeGroup *trackingKeyframes = [self newTrackingKeyframes];

    // map the tracking value by the current character offset:
    [trackingKeyframes remapKeyframesWithBlock:^CGFloat(CGFloat inValue) {
      // all characters width accumulated + preceeding chars count * tracking
      return preceedingCharactersWidths + ((tracking + inValue) * i);
    }];

    // map the tracking to x,y points
    for (LOTKeyframe *frame in trackingKeyframes.keyframes) {
      [frame formPointFromFloatWithYValue:0];
    }

    // create a transform node for this character scaling it by the font scale and positioning it
    // in this frames character arrangment:
    LOTShapeTransform *transformNode = [self newTransformModelWithFontScale:_fontScale
                                                       andTrackingKeyframes:trackingKeyframes];

    // create a stroke node to stroke the outline of the character:
    // a 4 miter limit bezels angles <~30º this is the default value on Android and gives us parity
    // in text rendering.
    LOTShapeStroke *strokeNode = [[LOTShapeStroke alloc] initWithKeyname:character.characterString
                                                             colorFrames:_strokeColorKeyframes
                                                             widthFrames:_strokeWidthKeyframes
                                                           opacityFrames:[[LOTKeyframeGroup alloc] initWithData:@1]
                                                              miterLimit: 4.0];

    NSArray *strokeItems = [character.shapes.items arrayByAddingObject:strokeNode];
    LOTShapeGroup *strokeGroup = [[LOTShapeGroup alloc] initWithKeyname:character.characterString
                                                                 shapes:strokeItems];

    // create a fill node fot fill the character:
    LOTShapeFill *fillNode = [[LOTShapeFill alloc] initWithKeyName:character.characterString
                                                    colorKeyframes:_fillColorKeyframes
                                                  opacityKeyframes:[[LOTKeyframeGroup alloc] initWithData:@1]];

    NSArray *fillItems = [character.shapes.items arrayByAddingObject:fillNode];

    LOTShapeGroup *fillGroup = [[LOTShapeGroup alloc] initWithKeyname:character.characterString
                                                               shapes:fillItems];

    // arrange nodes based on "overfill":
    NSArray *characterGroups;
    // these are "fifo" because the render group always inserts at the 0 index so [stroke, fill]
    // renders as fill, stroke in the layer heirarchy
    if (_properties.strokeOverfill) {
      characterGroups = @[strokeGroup, fillGroup];
    } else {
      characterGroups = @[fillGroup, strokeGroup];
    }

    NSArray *items = [characterGroups arrayByAddingObject:transformNode];

    [groupsArray addObject: [[LOTShapeGroup alloc] initWithKeyname:character.characterString
                                                            shapes:items]];
    // increment
    preceedingCharactersWidths += characterWidth;
  }

  _frameGroups = groupsArray;
}

/// returns a copy of the existing tracking keyframes or creates a new keyframe group with the
/// default tracking of the text properties' tracking
- (LOTKeyframeGroup*)newTrackingKeyframes {
  if (_animations.tracking) {
    return [_animations.tracking copy];
  } else {
    LOTKeyframe *defaultTracking = [[LOTKeyframe alloc] initWithValue:_properties.tracking];
    return [[LOTKeyframeGroup alloc] initWithKeyframes:@[defaultTracking]];
  }
}

- (LOTShapeTransform*)newTransformModelWithFontScale:(CGFloat)fontScale
                                andTrackingKeyframes:(LOTKeyframeGroup*)trackingKeyframes {

  LOTKeyframe *scale = [[LOTKeyframe alloc] initWithSizeValue:CGSizeMake(fontScale, fontScale)];
  LOTKeyframeGroup *scaleGroup = [[LOTKeyframeGroup alloc] initWithKeyframes:@[scale]];

  return [[LOTShapeTransform alloc] initWithPositionKeyframes:trackingKeyframes
                                               scaleKeyframes:scaleGroup
                                             opacityKeyframes:_opacityKeyframes];
}

@end
