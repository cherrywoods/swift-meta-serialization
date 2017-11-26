// swift-tools-version:4.0.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetaSerialization",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MetaSerialization",
            targets: ["MetaSerialization iOS",
                      "MetaSerialization watchOS",
                      "MetaSerialization tvOS",
                      "MetaSerialization macOS"]),
    ],
    dependencies: [
        // no depdependencies
    ],
    targets: [
        // targets for macOS, iOS, tvOS and watchOS, plus one unit testing target for macOS
        .target(
            name: "MetaSerialization iOS",
            path: "./Sources",
            /*sources defaults to nil, which means use all valid source files*/
        /*
        .target(
            name: "MetaSerialization watchOS",
            path: "./Sources",
        .target(
            name: "MetaSerialization tvOS",
            path: "./Sources",
        .target(
            name: "MetaSerialization macOS",
            path: "./Sources",
        .testTarget(
            name: "MetaSerializationTests macOS",
            dependencies: ["MetaSerialization macOS"],
            path: "./Tests",
            sources: ["meta_serialization_macOSTests.swift", "Tree.swift", "Tree+Equatable.swift", "UselessTranslators.swift"]),
        */
    ]
)
