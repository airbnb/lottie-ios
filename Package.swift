// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "Lottie",
  platforms: [.iOS("11.0"), .macOS("10.10"), .tvOS("11.0")],
  products: [
    .library(name: "Lottie", targets: ["Lottie"]),
    .library(name: "_LottieCore", targets: ["LottieCore"]),
  ],
  dependencies: [
    .package(
      name: "SnapshotTesting",
      url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
      .revision("0259c2fbd69c7bfaa34b0b86280496f84653e396")),
  ],
  targets: [
    .target(
      name: "Lottie",
      dependencies: ["LottieCore"],
      path: "Sources",
      exclude: ["Public", "Private"]),

    // The primary library target that contains the Lottie package
    //  - This target is imported and re-exported by the "Lottie" SPM target
    //    and the "Lottie" Carthage framework.
    .target(
      name: "LottieCore",
      path: "Sources",
      exclude: ["Lottie.swift"]),

    .testTarget(
      name: "LottieTests",
      dependencies: ["Lottie", "SnapshotTesting"],
      path: "Tests",
      exclude: ["Artifacts"],
      resources: [.copy("Samples"), .process("__Snapshots__")]),
  ])
