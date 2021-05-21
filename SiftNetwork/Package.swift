// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SiftNetwork",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SiftNetwork",
            targets: ["SiftNetwork"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SiftNetwork",
            dependencies: []),
        .testTarget(
            name: "SiftNetworkTests",
            dependencies: ["SiftNetwork"]),
    ]
)
