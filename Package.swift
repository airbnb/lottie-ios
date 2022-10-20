// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "Lottie",
  platforms: [.iOS("11.0"), .macOS("10.10"), .tvOS("11.0")],
  products: [.library(name: "Lottie", targets: ["Lottie"])],
  dependencies: [.package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))],
  targets: [.target(name: "Lottie", dependencies: ["ZIPFoundation"], path: "Sources")])
