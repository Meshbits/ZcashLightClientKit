// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "ZcashLightClientKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ZcashLightClientKit",
            targets: ["ZcashLightClientKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.19.1"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1"),
        .package(url: "https://github.com/piratenetwork/pirate-light-client-ffi.git", revision: "b07e6fb619a8f0eadd344f4e0d3e81d8a7a0a33a")
    ],
    targets: [
        .target(
            name: "ZcashLightClientKit",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "libpiratelc", package: "pirate-light-client-ffi")
            ],
            exclude: [
                "Modules/Service/GRPC/ProtoBuf/proto/compact_formats.proto",
                "Modules/Service/GRPC/ProtoBuf/proto/proposal.proto",
                "Modules/Service/GRPC/ProtoBuf/proto/service.proto",
                "Error/Sourcery/"
            ],
            resources: [
                .copy("Resources/checkpoints")
            ]
        ),
        .target(
            name: "TestUtils",
            dependencies: ["ZcashLightClientKit"],
            path: "Tests/TestUtils",
            exclude: [
                "proto/darkside.proto",
                "Sourcery/AutoMockable.stencil",
                "Sourcery/generateMocks.sh"
            ],
            resources: [
                .copy("Resources/test_data.db"),
                .copy("Resources/cache.db"),
                .copy("Resources/darkside_caches.db"),
                .copy("Resources/darkside_data.db"),
                .copy("Resources/sandblasted_mainnet_block.json"),
                .copy("Resources/txBase64String.txt"),
                .copy("Resources/txFromAndroidSDK.txt"),
                .copy("Resources/integerOverflowJSON.json"),
                .copy("Resources/sapling-spend.params"),
                .copy("Resources/sapling-output.params")
            ]
        ),
        .testTarget(
            name: "OfflineTests",
            dependencies: ["ZcashLightClientKit", "TestUtils"]
        ),
        .testTarget(
            name: "NetworkTests",
            dependencies: ["ZcashLightClientKit", "TestUtils"]
        ),
        .testTarget(
            name: "DarksideTests",
            dependencies: ["ZcashLightClientKit", "TestUtils"]
        ),
        .testTarget(
            name: "AliasDarksideTests",
            dependencies: ["ZcashLightClientKit", "TestUtils"],
            exclude: [
                "scripts/"
            ]
        ),
        .testTarget(
            name: "PerformanceTests",
            dependencies: ["ZcashLightClientKit", "TestUtils"]
        )
    ]
)
