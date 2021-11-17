// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "MTKScrollView",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "MTKScrollView",
            targets: ["MTKScrollView"]),
    ],
    targets: [
        .target(
            name: "MTKScrollView",
            dependencies: []),
        .testTarget(
            name: "MTKScrollViewTests",
            dependencies: ["MTKScrollView"]),
    ]
)
