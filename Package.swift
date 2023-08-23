// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "Lottie",
  // Minimum platform versions should be kept in sync with the per-platform targets in 
  // Package@swift-5.5.swift, Lottie.xcodeproj, lottie-ios.podspec, and lottie-spm's Package.swift
  platforms: [.iOS("11.0"), .macOS("10.11"), .tvOS("11.0"), .visionOS("1.0")],
  products: [.library(name: "Lottie", targets: ["Lottie"])],
  dependencies: [
    .package(url: "https://github.com/airbnb/swift", .upToNextMajor(from: "1.0.1"))
  ],
  targets: [
    .target(
      name: "Lottie",
      path: "Sources",
      exclude: [
        "Private/EmbeddedLibraries/README.md",
        "Private/EmbeddedLibraries/ZipFoundation/README.md",
        "Private/EmbeddedLibraries/EpoxyCore/README.md",
      ]),
  ])
