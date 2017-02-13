//
//  LAAnimatedTextField.m
//  LottieExamples
//
//  Created by Brandon Withrow on 1/10/17.
//  Copyright © 2017 Brandon Withrow. All rights reserved.
//

#import "AnimatedTextField.h"
#import <Lottie/Lottie.h>

@interface LACharacterCell : UICollectionViewCell

- (void)setCharacter:(NSString *)character;
- (void)displayCharacter:(BOOL)animated;
- (void)loopAnimation;

@end

@implementation LACharacterCell {
  LOTAnimationView *animationView_;
  NSString *character_;
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

- (void)setCharacter:(NSString *)character {
  
  
  NSString *sanitizedCharacter = [character substringToIndex:1];
  NSCharacterSet *alphaSet = [NSCharacterSet letterCharacterSet];
  BOOL valid = [[sanitizedCharacter stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
  
  
  if ([character isEqualToString:@"BlinkingCursor"]) {
    sanitizedCharacter = character;
  }
  if ([sanitizedCharacter isEqualToString:@","]) {
    sanitizedCharacter = @"Comma";
    valid = YES;
  }
  if ([sanitizedCharacter isEqualToString:@"'"]) {
    sanitizedCharacter = @"Apostrophe";
    valid = YES;
  }
  if ([sanitizedCharacter isEqualToString:@":"]) {
    sanitizedCharacter = @"Colon";
    valid = YES;
  }
  if ([sanitizedCharacter isEqualToString:@"?"]) {
    sanitizedCharacter = @"QuestionMark";
    valid = YES;
  }
  if ([sanitizedCharacter isEqualToString:@"!"]) {
    sanitizedCharacter = @"ExclamationMark";
    valid = YES;
  }
  if ([sanitizedCharacter isEqualToString:@"."]) {
    sanitizedCharacter = @"Period";
    valid = YES;
  }

  if ([sanitizedCharacter isEqualToString:character_]) {
    return;
  }
  
  [animationView_ removeFromSuperview];
  animationView_ = nil;
  character_ = nil;

  if (!valid) {
    return;
  }
  character_ = sanitizedCharacter;
  LOTAnimationView *animationView = [LOTAnimationView animationNamed:sanitizedCharacter];
  animationView_ = animationView;
  animationView_.contentMode = UIViewContentModeScaleAspectFit;
  [self.contentView addSubview:animationView_];
  CGRect c = self.contentView.bounds;
  animationView_.frame = CGRectMake(-c.size.width, 0, c.size.width * 3, c.size.height);
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGRect c = self.contentView.bounds;
  animationView_.frame = CGRectMake(-c.size.width, 0, c.size.width * 3, c.size.height);
}

- (void)displayCharacter:(BOOL)animated {
  if (animated) {
    [animationView_ play];
  } else  {
      animationView_.animationProgress = 1;
  }
}

- (void)loopAnimation {
  animationView_.loopAnimation = YES;
}

@end

@interface AnimatedTextField () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation AnimatedTextField {
  NSString *_text;
  UICollectionView *_collectionView;
  UICollectionViewFlowLayout *_layout;
  BOOL _updatingCells;
  NSArray *letterSizes_;
}

#pragma mark -- UIView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _fontSize = 36;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_layout];
    [_collectionView registerClass:[LACharacterCell class] forCellWithReuseIdentifier:@"char"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_collectionView];
    
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _collectionView.frame = self.bounds;
}

#pragma mark -- External

- (void)setFontSize:(NSInteger)fontSize {
  _fontSize = fontSize;
  [self _computeLetterSizes];
  [_layout invalidateLayout];
}

- (void)scrollToBottom {
  CGPoint bottomOffset = CGPointMake(0, _collectionView.contentSize.height - _collectionView.bounds.size.height + _collectionView.contentInset.bottom);
  bottomOffset.y = MAX(bottomOffset.y, 0);
  [_collectionView setContentOffset:bottomOffset animated:YES];
}

- (void)setScrollInsets:(UIEdgeInsets)scrollInsets {
  [_collectionView setContentInset:scrollInsets];
  [self scrollToBottom];
}

- (void)setText:(NSString *)text {
  _text = text;
  [self _computeLetterSizes];
  [_collectionView reloadData];
  [self scrollToBottom];
}

- (void)changeCharactersInRange:(NSRange)range
                       toString:(NSString *)replacementString {
  NSMutableString *newText = [_text mutableCopy];
  if (range.location > 0) {
     [newText replaceCharactersInRange:range withString:replacementString];
  }
  
  NSMutableArray *updateIndices, *addIndices, *removeIndices;

  for (NSUInteger i = range.location; i < newText.length; i ++) {
    if (i < _text.length) {
      if (!updateIndices) {
        updateIndices = [NSMutableArray array];
      }
      [updateIndices addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    } else {
      if (!addIndices) {
        addIndices = [NSMutableArray array];
      }
      [addIndices addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
  }
  
  for (NSUInteger i = newText.length; i < _text.length; i ++) {
    if (!removeIndices) {
      removeIndices = [NSMutableArray array];
    }
    [removeIndices addObject:[NSIndexPath indexPathForRow:i inSection:0]];
  }

  _updatingCells = YES;
  _text = newText;
  [self _computeLetterSizes];
  [_collectionView performBatchUpdates:^{
    if (addIndices) {
      [_collectionView insertItemsAtIndexPaths:addIndices];
    }
    if (updateIndices) {
      [_collectionView reloadItemsAtIndexPaths:updateIndices];
    }
    if (removeIndices) {
      [_collectionView deleteItemsAtIndexPaths:removeIndices];
    }
  } completion:^(BOOL finished) {
    _updatingCells = NO;
  }];
  [self scrollToBottom];
}

#pragma mark -- Internal

- (NSString*)_characterAtIndexPath:(NSIndexPath *)indexPath {
  return [_text substringWithRange:NSMakeRange(indexPath.row, 1)].uppercaseString;
}

- (void)_computeLetterSizes {
  NSMutableArray *sizes = [NSMutableArray array];
  CGFloat width = self.bounds.size.width;
  CGFloat currentWidth = 0;
  
  for (NSInteger i = 0; i < _text.length; i ++) {
    NSString *letter = [_text substringWithRange:NSMakeRange(i, 1)].uppercaseString;
    CGSize letterSize = [self _sizeOfString:letter];
    
    if ([letter isEqualToString:@" "] && i + 1 < _text.length) {
      NSString *cutString = [_text substringFromIndex:i + 1];
      NSArray *words = [cutString componentsSeparatedByString:@" "];
      
      if (words.count) {
        CGSize nextWordLength = [self _sizeOfString:words.firstObject];
        if (currentWidth + nextWordLength.width + letterSize.width > width) {
          letterSize.width = floorf(width - currentWidth);
          currentWidth = 0;
        } else {
          currentWidth += letterSize.width;
        }
      }
    } else {
      currentWidth += letterSize.width;
      if (currentWidth >= width) {
        currentWidth = letterSize.width;
      }
    }
    [sizes addObject:[NSValue valueWithCGSize:letterSize]];
  }
  CGSize cursorSize = [self _sizeOfString:@"W"];
  [sizes addObject:[NSValue valueWithCGSize:cursorSize]];
  letterSizes_ = sizes;
}

- (CGSize)_sizeOfString:(NSString *)string {
  CGSize constraint = CGSizeMake(1000, 1000);
  CGSize textSize = [string.uppercaseString boundingRectWithSize:constraint
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:self.fontSize] }
                                                         context:nil].size;
  textSize.width += (string.length * 2);
  return textSize;
}

#pragma mark -- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return _text.length + 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  LACharacterCell *charCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"char" forIndexPath:indexPath];
  return charCell;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(LACharacterCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < _text.length) {
    [cell setCharacter:[self _characterAtIndexPath:indexPath]];
    [cell displayCharacter:_updatingCells];
  } else {
    [cell setCharacter:@"BlinkingCursor"];
    [cell loopAnimation];
    [cell displayCharacter:YES];
  }
}
#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row >= letterSizes_.count) {
    return CGSizeZero;
  }
  NSValue *value = letterSizes_[indexPath.row];
  return value.CGSizeValue;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
                   minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
                   minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  return 0;
}

@end
