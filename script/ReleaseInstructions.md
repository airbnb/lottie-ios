## Release Instructions for Lottie iOS

Lottie is made available through multiple package managers, each of which has to be updated individually for each release.

 1. Make sure `lottie-ios.podspec` and `package.json` list the correct version number
 2. Update the [Cocoapod](https://cocoapods.org/pods/lottie-ios) by running `pod trunk push lottie-ios.podspec`
 3. Update the [npm package](https://www.npmjs.com/package/lottie-ios) by running `npm publish`
 4. Attach `Lottie.xframework.zip` to the GitHub release and include the checksum in the release notes.
   - For every PR / commit, `Lottie.xcframework.zip` is build by CI and uploaded to the job summary.