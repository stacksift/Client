// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Models",
            targets: ["Models"]),
    ],
    dependencies: [
        .package(path: "../SiftServices"),
    ],
    targets: [
        .target(name: "Models", dependencies: ["SiftServices"]),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["Models"],
            resources: [
                .copy("Resources/08a3eb98c83a4ab9b9cc7a890967b4a8.report"),
                .copy("Resources/08a3eb98c83a4ab9b9cc7a890967b4a8.crash"),
            ]),
    ]
)
