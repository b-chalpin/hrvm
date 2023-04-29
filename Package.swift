// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hrv_standalone_watch_app",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "hrv_standalone_watch_app",
            targets: ["hrv_standalone_watch_app"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "hrv_standalone_watch_app"),
        .testTarget(
            name: "hrv_standalone_watch_appTests",
            dependencies: ["hrv_standalone_watch_app"]),
    ]
)
