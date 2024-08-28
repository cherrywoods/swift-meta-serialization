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
        .target(
            name: "MetaSerialization",
            exclude: [
                "Info.plist",
                "README.md",
                "Encoder/README.md",
                "Decoder/README.md",
                "Coding Storage/README.md",
            ]
        ),
        .testTarget(
            name: "MetaSerializationTests",
            dependencies: [
                .byName(name: "Quick"),
                .byName(name: "Nimble"),
                .target(name: "MetaSerialization")
            ], 
            exclude: [
                "Info.plist",
                "README.md",
                "Examples/README.md",
                "Examples/Example1/README.md",
                "Examples/Example3/README.md",
                "Examples/DynamicUnwrap/README.md",
            ]
        ),
        .testTarget(
            name: "TestAssertionGuarded",
            dependencies: [
                .byName(name: "Quick"),
                .byName(name: "Nimble"),
                .target(name: "MetaSerialization")
            ], 
            exclude: [
                "Info.plist",
                "README.md"
            ]
        )
    ]
)
