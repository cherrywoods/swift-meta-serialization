// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetaSerialization",
    products: [
        .library(name: "MetaSerialization", targets: ["MetaSerialization"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),
    ],
    targets: [
        .target(
            name: "MetaSerialization",
            path: "Sources"
        ),
        .testTarget(
            name: "MetaSerializationTests",
            dependencies: [
                .byName(name: "Quick"),
                .byName(name: "Nimble"),
                .target(name: "MetaSerialization"),
            ], 
            path: "Tests"
        ),
    ]
)
