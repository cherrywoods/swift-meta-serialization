// swift-tools-version:5.7

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
        .target(name: "MetaSerialization"),
        .testTarget(
            name: "MetaSerializationTests",
            dependencies: [
                .byName(name: "Quick"),
                .byName(name: "Nimble"),
                .target(name: "MetaSerialization")
            ], 
            exclude: [
                "Tests/Info.plist"
            ]
        )
    ]
)
