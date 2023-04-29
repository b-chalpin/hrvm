// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sources/hrvm_new",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Sources/hrvm_new",
            targets: ["Sources/hrvm_new"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Sources/hrvm_new"),
        .testTarget(
            name: "hrvm_newTests",
            dependencies: ["Sources/hrvm_new"]),
    ]
)
