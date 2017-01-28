# Lottie for iOS (and [Android](https://github.com/airbnb/lottie-android))

Lottie is a mobile library for Andorid and iOS that parses [Adobe After Effects](http://www.adobe.com/products/aftereffects.html) animations exported as json with [bodymovin](https://github.com/bodymovin/bodymovin) and renders the vector animations natively on mobile and through React Native!



For the first time, designers can create **and ship** beautiful animations without an enginineer painstakingly recreating it be hand.
Since the animation is backed by JSON they are extremely small in size but can be large in complexity!
Animations can be played, resized, looped, sped up, slowed down, and even interactively scrubbed.

Lottie also supports native UIViewController Transitions out of the box!

* [Painstaking example 1](http://jeremie-martinez.com//2016/09/15/train-animations/)
* [Painstaking example 2](https://blog.twitter.com/2015/hearts-on-twitter)
* [Painstaking example 3](https://medium.com/@crafty/animation-jump-through-861f4f5b3de4#.lvq6k8lb5)

Here is just a small sampling of the power of Lottie

![Example1](_Gifs/Examples1.gif)
![Example2](_Gifs/Examples2.gif)

![Community](_Gifs/Community 2_3.gif)
![Example3](_Gifs/Examples3.gif)

![Abcs](_Gifs/Examples4.gif)

## Using Lottie
Lottie supports iOS 8 and above.
Lottie animations can be loaded from bundled JSON or from a URL

The simplest way to use it is with LAAnimationView:
```
LAAnimation *animation = [LAAnimationView animationNamed:@"Lottie"];
[self.view addSubview:animation];
[animation playWithCompletion:^(BOOL animationFinished) {
  // Do Something
}];
```

Or you can load it programatically from a NSURL
```
LAAnimation *animation = [[LAAnimationView alloc] initWithContentsOfURL:[NSURL URLWithString:URL]];
[self.view addSubview:animation];
```

Lottie supports the iOS `UIViewContentModes` aspectFit and aspectFill

You can also set the animation progress interactively.
```
CGPoint translation = [gesture getTranslationInView:self.view];
CGFloat progress = translation.y / self.view.bounds.size.height;
animationView.animationProgress = progress;
```

Want to mask arbitrary views to animation layers in a Lottie View?
Easy-peasy as long as you know the name of the layer from After Effects

```
UIView *snapShot = [self.view snapshotViewAfterScreenUpdates:YES];
[lottieAnimation addSubview:snapShot toLayerNamed:@"AfterEffectsLayerName"];
```

Lottie comes with a UIViewController animation controller for making custom viewController transitions!

```
#pragma mark -- View Controller Transitioning

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
  LAAnimationTransitionController *animationController = [[LAAnimationTransitionController alloc] initWithAnimationNamed:@"vcTransition1"
                                                                                                          fromLayerNamed:@"outLayer"
                                                                                                            toLayerNamed:@"inLayer"];
  return animationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
  LAAnimationTransitionController *animationController = [[LAAnimationTransitionController alloc] initWithAnimationNamed:@"vcTransition2"
                                                                                                          fromLayerNamed:@"outLayer"
                                                                                                            toLayerNamed:@"inLayer"];
  return animationController;
}

```

If your animation will be frequently reused, `LAAnimationView` has an built in LRU Caching Strategy.

## Supported After Effects Features

### Keyframe Interpolation

---

* Linear Interpolation

* Bezier Interpolation

* Hold Interpolation

* Rove Across Time

* Spatial Bezier

### Solids

---

* Transform Anchor Point

* Transform Position

* Transform Scale

* Transform Rotation

* Transform Opacity

### Masks

---

* Path

* Opacity

* Multiple Masks (additive)

### Track Mattes

---

* Alpha Matte

### Parenting

---

* Multiple Parenting

* Nulls

### Shape Layers

---

* Anchor Point

* Position

* Scale

* Rotation

* Opacity

* Path

* Group Transforms (Anchor point, position, scale etc)

* Rectangle (All properties)

* Elipse (All properties)

* Multiple paths in one group

#### Stroke (shape layer)

---

* Stroke Color

* Stroke Opacity

* Stroke Width

* Line Cap

* Dashes

#### Fill (shape layer)

---

* Fill Color

* Fill Opacity

#### Trim Paths (shape layer)

---

* Trim Paths Start

* Trim Paths End

* Trim Paths Offset

## Try it out

Lottie Uses Cocoapods!
Get the Cocoapod or clone this repo and try out [the Example App](https://github.com/airbnb/lottie-ios/tree/master/Example)

## Alternatives
1. Build animations by hand. Building animations by hand is a huge time commitment for design and engingeering across Android and iOS. It's often hard or even impossible to justify spending so much time to get an animation right.
2. [Facebook Keyframes](https://github.com/facebookincubator/Keyframes). Keyframes is a wonderful new library from Facebook that they built for reactions. However, Keyframes doesn't support some of Lottie's features such as masks, mattes, trim paths, dash patterns, and more.
2. Gifs. Gifs are more than double the size of a bodymovin JSON and are rendered at a fixed size that can't be scaled up to match large and high density screens.
3. Png sequences. Png sequences are even worse than gifs in that their file sizes are often 30-50x the size of the bodymovin json and also can't be scaled up.

## Why is it called Lottie?
Lottie is named after a German film director and the foremost pioneer of silhouette animation. Her best known films are The Adventures of Prince Achmed (1926) – the oldest surviving feature-length animated film, preceding Walt Disney's feature-length Snow White and the Seven Dwarfs (1937) by over ten years
[The art of Lotte Reineger](https://www.youtube.com/watch?v=LvU55CUw5Ck&feature=youtu.be)

## Contributing
Contributors are more than welcome. Just upload a PR with a description of your changes.

If you would like to add more JSON files and screenshot tests, feel free to do so and add the test to `LottieTest`.

## Issues or feature requests?
File github issues for anything that is unexpectedly broken. If an After Effects file is not working, please attach it to your issue. Debugging without the original file is much more difficult.

## Roadmap
- Add support for interactive animated transitions
- Add support for parenting programatically added layers, moving/scaling
- Support for the After Effects Trim Paths Offset feature
- Animation Syncing
- Programatically alter animations

