// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "Lottie",
  // Minimum platform versions should be kept in sync with the per-platform targets in Lottie.xcodeproj, lottie-ios.podspec, and lottie-spm's Package.swift
  platforms: [.iOS("13.0"), .macOS("10.15"), .tvOS("13.0"), .custom("visionOS", versionString: "1.0")],
  products: [
    .library(name: "Lottie", targets: ["Lottie"]),
    // Product for dynamic linking, as SPM builds libraries statically by default.
    // This product should be used in a modular project structure with multiple packages using Lottie to avoid duplicate symbols.
    .library(name: "Lottie-Dynamic", type: .dynamic, targets: ["Lottie"]),
  ],
  dependencies: [
    .package(url: "https://github.com/airbnb/swift", .upToNextMajor(from: "1.0.1")),
  ],
  targets: [
    .target(
      name: "Lottie",
      path: "Sources",
      exclude: [
        "Private/EmbeddedLibraries/README.md",
        "Private/EmbeddedLibraries/ZipFoundation/README.md",
        "Private/EmbeddedLibraries/EpoxyCore/README.md",
        "Private/EmbeddedLibraries/LRUCache/README.md",
      ],
      resources: [.copy("PrivacyInfo.xcprivacy")]),
  ])
