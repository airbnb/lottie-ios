// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lottie",
    platforms: [.iOS(.v8)],
    products: [
        .library(name: "Lottie", targets: ["Lottie"]),
    ],
    targets: [
        .target(
            name: "Lottie",
            path: "lottie-ios/Classes",
            publicHeadersPath: "include"
        ),
    ]
)
