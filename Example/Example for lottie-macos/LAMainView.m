//
//  LAMainView.m
//  lottie-ios
//
//  Created by brandon_withrow on 8/1/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "LAMainView.h"
#import <Lottie/Lottie.h>

@interface LAMainView ()

@property (nonatomic, strong) LOTAnimationView *lottieLogo;

@end
@implementation LAMainView

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (instancetype)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)commonInit {
  NSArray *dragTypes = [NSArray arrayWithObjects:NSFilenamesPboardType, nil];
  [self registerForDraggedTypes:dragTypes];
  
  self.lottieLogo = [LOTAnimationView animationNamed:@"LottieLogo1"];
  self.lottieLogo.contentMode = LOTViewContentModeScaleAspectFill;
  self.lottieLogo.frame = self.bounds;
  self.lottieLogo.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  self.lottieLogo.layer.zPosition = -10000;
  [self addSubview:self.lottieLogo];
}

- (void)viewDidMoveToSuperview {
  [self.lottieLogo play];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
  NSPasteboard *pboard;
  NSDragOperation sourceDragMask;
  
  sourceDragMask = [sender draggingSourceOperationMask];
  pboard = [sender draggingPasteboard];
  
  if ( [[pboard types] containsObject:NSColorPboardType] ) {
    if (sourceDragMask & NSDragOperationGeneric) {
      return NSDragOperationGeneric;
    }
  }
  if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
    if (sourceDragMask & NSDragOperationLink) {
      return NSDragOperationLink;
    } else if (sourceDragMask & NSDragOperationCopy) {
      return NSDragOperationCopy;
    }
  }
  return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
  NSPasteboard *pboard;
  NSDragOperation sourceDragMask;
  
  sourceDragMask = [sender draggingSourceOperationMask];
  pboard = [sender draggingPasteboard];
  
  if ( [[pboard types] containsObject:NSColorPboardType] ) {
    // Only a copy operation allowed so just copy the data
    
  } else if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    
    NSArray *jsonFiles = [files pathsMatchingExtensions:@[@"json"]];
    if (jsonFiles.count) {
      [self _openAnimationFile:jsonFiles.firstObject];
    }
    // Depending on the dragging source and modifier keys,
    // the file data may be copied or linked
    NSLog(@"FILES");
  }
  return YES;
}

- (void)_openAnimationFile:(NSString *)file {
  
  NSError *error;
  NSData *jsonData = [[NSData alloc] initWithContentsOfFile:file];
  NSDictionary  *JSONObject = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
                                                                         options:0 error:&error] : nil;
  if (JSONObject && !error) {
    LOTComposition *laScene = [[LOTComposition alloc] initWithJSON:JSONObject withAssetBundle:[NSBundle mainBundle]];
    laScene.rootDirectory = [file stringByDeletingLastPathComponent];
    self.lottieLogo.sceneModel = laScene;
    [self.lottieLogo play];
  }
}

-(void)openAnimationURL:(NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        NSError *error;
        NSData *jsonData = [[NSData alloc] initWithContentsOfURL:url];
        NSDictionary  *JSONObject = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData
                                                                               options:0 error:&error] : nil;
        if (JSONObject && !error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                LOTComposition *laScene = [[LOTComposition alloc] initWithJSON:JSONObject withAssetBundle:[NSBundle mainBundle]];
                self.lottieLogo.sceneModel = laScene;
                self.lottieLogo.contentMode = LOTViewContentModeScaleAspectFit;
                [self.lottieLogo play];
            });
        }
        
    });
}


- (void)setAnimationProgress:(CGFloat)progress {
  self.lottieLogo.animationProgress = progress;
}
- (void)playAnimation {
  if (self.lottieLogo.isAnimationPlaying) {
    [self.lottieLogo pause];
  } else {
    [self.lottieLogo play];
  }
}
- (void)rewindAnimation {
  [self.lottieLogo stop];
}
- (void)toggleLoop {
  self.lottieLogo.loopAnimation = !self.lottieLogo.loopAnimation;
}

@end
