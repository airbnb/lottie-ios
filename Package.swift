// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Lottie",
    products: [
        .library(name: "Lottie", targets: ["Lottie"])
    ],
    targets: [
        .target(
            name: "Lottie",
            path: "lottie-ios"
        )
    ]
)
