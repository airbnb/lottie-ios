// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Lottie",
    platforms: [.iOS(.v12)],
    // platforms: [.iOS("9.0"), .macOS("10.10"), tvOS("9.0"), .watchOS("2.0")],
    products: [
        .library(name: "Lottie", targets: ["Lottie"])
    ],
    targets: [
        .target(
            name: "Lottie",
            path: "lottie-swift/src",
            exclude: ["lottie-swift/src/Public/MacOS"]
        )
    ],
    swiftLanguageVersions: [.v4_2, .v5]
)
