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
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
        .package(url: "https://github.com/stacksift/OAuthenticator", from: "0.1.0"),
    ],
    targets: [
        .target(name: "SiftServices", dependencies: ["SiftNetwork"]),
        .target(name: "ServiceImplemenations", dependencies: ["SiftServices", "OAuthenticator", "KeychainAccess"]),
        .target(name: "MockServiceImplemenations", dependencies: ["SiftServices"]),
        .testTarget(name: "ServiceTests", dependencies: ["SiftServices"]),
    ]
)
