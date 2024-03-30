// swift-tools-version:4.0.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetaSerialization",
    products: [
        .library(name: "MetaSerializationMacOS", targets: ["MetaSerialization macOS"]),
        .library(name: "MetaSerializationIOS", targets: ["MetaSerialization iOS"]),
        .library(name: "MetaSerializationWatchOS", targets: ["MetaSerialization watchOS"]),
        .library(name: "MetaSerializationTVOS", targets: ["MetaSerialization tvOS"]),
    ]
)
