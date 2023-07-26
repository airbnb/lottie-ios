// Created by Cal Stephens on 7/26/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

public enum LottieAnimationSource {
  case lottieAnimation(LottieAnimation)
  case dotLottieFile(DotLottieFile)

  /// The animation displayed by this data source
  var animation: LottieAnimation? {
    switch self {
    case .lottieAnimation(let animation):
      return animation
    case .dotLottieFile(let dotLottieFile):
      return dotLottieFile.animation()?.animation
    }
  }
}
