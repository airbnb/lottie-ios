// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "Lottie",
  platforms: [.iOS("11.0"), .macOS("10.10"), .tvOS("11.0")],
  products: [
    .library(name: "Lottie", targets: ["Lottie"]),
  ],
  dependencies: [
    .package(url: "https://github.com/airbnb/swift", branch: "master"),
  ],
  targets: [
    .target(name: "Lottie", path: "Sources"),
  ])
