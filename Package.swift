// swift-tools-version:5.0
import PackageDescription

#if os(macOS)
let package = Package(
    name: "Lottie",
    platforms: [.macOS("10.9")],
    products: [
        .library(name: "Lottie", targets: ["Lottie"])
    ],
    targets: [
        .target(
            name: "Lottie",
            path: "lottie-swift/src",
            exclude: ["Public/iOS"]
        )
    ]
)
#else
let package = Package(
    name: "Lottie",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "Lottie", targets: ["Lottie"])
    ],
    targets: [
        .target(
            name: "Lottie",
            path: "lottie-swift/src",
            exclude: ["Public/MacOS"]
        )
    ]
)
#endif
