// swift-tools-version:4.0.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetaSerialization",
    products: [
        .library(name: "MetaSerialization", targets: ["MetaSerialization"]),
    ],
    targets: [
        .target(name: "MetaSerialization"),
    ]
)
