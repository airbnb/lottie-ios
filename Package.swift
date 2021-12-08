// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "Lottie",
  // TODO: Fix SPM support for macOS, tvOS, and watchOS.
  // https://github.com/airbnb/lottie-ios/issues/1361
  // platforms: [.iOS("9.0"), .macOS("10.10"), tvOS("9.0"), .watchOS("2.0")],
  platforms: [.iOS(.v9)],
  products: [
    .library(name: "Lottie", targets: ["Lottie"]),
  ],
  targets: [
    .target(name: "Lottie", path: "Sources", exclude: ["Public/MacOS"]),
  ])
