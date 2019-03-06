# Migrating from Lottie 2.5.2(OBJC) -> 3.0 (SWIFT)

Lottie 3.0 is a complete rewrite of Lottie in swift. Because of this there are some minor API changes. This guide should help you through migrating code from Lottie 2.5.2 to 3.0

Swift discourages the use of Prefix for names. A lot of the api changes are just the removal of `LOT` from the class name. Below is a complete list of API changes.

To use Lottie Swift in an Objective-C project read Apple's offical documentation [here](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_swift_into_objective-c)

## Class Changes
| Lottie 2.5.2 | Lottie 3.0+ |
| --:|  --:|
|`LOTAnimationView`|`AnimationView`|
|`LOTComposition`|`Animation`|
|`LOTKeypath`|`AnimationKeypath`|
|`LOTAnimationCache`|`AnimationCacheProvider`|
|`LOTCacheProvider`|`AnimationImageProvider`|
|`LOTValueDelegate`|`AnyValueProvider`|
|`LOTAnimatedControl`|`AnimatedControl`|
|⛔️|`AnimatedButton`|
|`LOTAnimatedSwitch`|`AnimatedSwitch`|

## Method Changes

| Lottie 2.5.2 | Lottie 3.0+ |
| --:|  --:|
|`LOTAnimationView.sceneModel`|`AnimationView.animation`|
|`LOTAnimationView.loopAnimation`|`AnimationView.loopMode`|
|`LOTAnimationView.autoReverseAnimation`|`AnimationView.loopMode`|
|`LOTAnimationView.animationProgress`|`AnimationView.currentProgress`|
|`LOTAnimationView.cacheEnable`|⛔️(Cache is passed in on init)|
|`LOTAnimationView.setValueDelegate:forKeypath:`|`AnimationView.setValueProvider:keypath:`|
|`LOTComposition.animationNamed:`|`Animation.named:`|
|`LOTComposition.animationWithFilePath:`|`Animation.filepath:`|
|`LOTComposition.animationNamed:inBundle:`|`Animation.named:bundle:`|
|`LOTComposition.animationFromJSON:`|⛔️(`Animation` is Encodable/Decodable from data on it's own.)|
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE1NDEwODc0Ml19
-->
