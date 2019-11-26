// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "Lottie",
  platforms: [.iOS(.v9), .macOS("10.10"), .tvOS("9.0")],
  products: [
    .library(name: "Lottie-ios", targets: ["Lottie-ios"]),
    .library(name: "Lottie-macos", targets: ["Lottie-macos"]),
  ],
  targets: [
    .target(
      name: "Lottie-ios",
      path: "lottie-swift/src",
      exclude: ["Public/MacOS"]
    ),
    .target(
      name: "Lottie-macos",
      path: "lottie-swift/src",
      exclude: ["Public/iOS"]
    )
  ]
)
