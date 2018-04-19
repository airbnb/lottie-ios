//
//  LOTTextRenderer.h
//  Lottie
//
//  Created by Adam Tierney on 4/19/18.
//  Copyright © 2018 Airbnb. All rights reserved.
//

#import "LOTText.h"
#import "LOTTextAnimations.h"
#import "LOTRenderNode.h"

@interface LOTTextRenderer : LOTRenderNode

- (instancetype _Nonnull)initWithInputNode:(LOTAnimatorNode *_Nullable)inputNode
                                  document:(LOTText *_Nonnull)text;
@end
