// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "Lottie",
  platforms: [.iOS("11.0"), .macOS("10.10"), .tvOS("11.0")],
  products: [
    .library(name: "Lottie", targets: ["Lottie"]),
  ],
  dependencies: [
    .package(
      name: "SnapshotTesting",
      url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
      .revision("0259c2fbd69c7bfaa34b0b86280496f84653e396")),
  ],
  targets: [
    .target(name: "Lottie", path: "Sources"),
    .testTarget(
      name: "LottieTests",
      dependencies: ["Lottie", "SnapshotTesting"],
      path: "Tests",
      exclude: ["Artifacts"],
      resources: [.process("Samples"), .process("__Snapshots__")]),
  ])
