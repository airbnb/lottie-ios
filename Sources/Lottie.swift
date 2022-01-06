// Created by Cal Stephens on 12/21/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

/// The SPM `Lottie` library, and Carthage `Lottie` framework
/// are "umbrella frameworks" that export the underlying
/// `LottieCore` SPM target that contains the actual implementation.
///
/// This is necessary to support Carthage, which requires a
/// `.framework` target called `Lottie`. SPM doesn't create
/// framework targets, so we define it in `CarthageSupport.xcodeproj`
/// have have it export the underlying `LottieCore` SPM target.
///
/// For consistency, we follow the same pattern for
/// the SPM `Lottie` target.
@_exported import LottieCore
