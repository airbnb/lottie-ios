## Release Instructions for Lottie iOS

Lottie is made available through multiple package managers, each of which has to be updated individually for each release.

 1. Make sure `lottie-ios.podspec`, `package.json`, and `Version.xcconfig` list the correct version number. 
   - Optionally, consider updating the version number in `README.md` as well.
   - Also consider updating the version number referenced here: https://airbnb.io/lottie/#/ios?id=swift-package-manager
 2. Publish the new release in the [lottie-ios](https://github.com/airbnb/lottie-ios) repo
 3. Update the [Cocoapod](https://cocoapods.org/pods/lottie-ios) by running `pod trunk push lottie-ios.podspec`
 4. Update the [npm package](https://www.npmjs.com/package/lottie-ios) by running `npm publish`
 5. Attach `Lottie.xframework.zip` to the GitHub release
   - For every PR / commit, `Lottie.xcframework.zip` is built by CI and uploaded to the job summary once all jobs are completed.
   - Make sure to use the `Lottie.xcframework.zip` from the CI job for the commit on master / the specific release tag and not from a PR CI job.
 6. Update the [lottie-spm](https://github.com/airbnb/lottie-spm) [Package.swift](https://github.com/airbnb/lottie-spm/blob/main/Package.swift) manifest to reference the new version's XCFramework.
   - You can compute the checksum by running `swift package compute-checksum Lottie.xcframework.zip`.
   - Optionally, consider updating the version number in `README.md` as well.
 7. Publish the new release in the [lottie-spm](https://github.com/airbnb/lottie-spm) repo
