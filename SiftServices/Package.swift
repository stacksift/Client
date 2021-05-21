// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SiftServices",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SiftServices",
            targets: ["SiftServices", "ServiceImplemenations", "MockServiceImplemenations"]),
    ],
    dependencies: [
        .package(path: "../SiftNetwork"),
        .package(path: "../OAuth"),
    ],
    targets: [
        .target(name: "SiftServices", dependencies: ["SiftNetwork"]),
        .target(name: "ServiceImplemenations", dependencies: ["SiftServices", "OAuth"]),
        .target(name: "MockServiceImplemenations", dependencies: ["SiftServices"]),
        .testTarget(name: "ServiceTests", dependencies: ["SiftServices"]),
    ]
)
