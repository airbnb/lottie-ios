// swift-tools-version:5.6
import PackageDescription

let package = Package(
  name: "Lottie",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13)
  ],
  products: [
    .library(
        name: "Lottie",
        targets: ["Lottie"]
    ),
  ],
  // Add required dependencies when working directly with package
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.10.0"),
    .package(url: "https://github.com/krzysztofzablocki/Difference.git", from: "1.0.0"),
    .package(url: "https://github.com/airbnb/epoxy-ios.git", from: "0.7.0")
  ],
  targets: [
    .target(name: "Lottie",
            dependencies: [
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Difference", package: "Difference"),
                .product(name: "Epoxy", package: "epoxy-ios")
            ],
            path: "Sources"),
    
    .testTarget(name: "LottieTest",
               dependencies: ["Lottie"],
                exclude: [
                    "__Snapshots__"
                ]
    )
  ]
)

#if swift(>=5.6)
// Add the Airbnb Swift formatting plugin if possible
package.dependencies.append(.package(url: "https://github.com/airbnb/swift", .upToNextMajor(from: "1.0.1")))
#endif
