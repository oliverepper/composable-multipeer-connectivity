// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "composable-multipeer-connectivity",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "ComposableMultipeerConnectivity",
            targets: ["ComposableMultipeerConnectivity"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.18.0")
    ],
    targets: [
        .target(
            name: "ComposableMultipeerConnectivity",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]),
        .testTarget(
            name: "ComposableMultipeerConnectivityTests",
            dependencies: ["ComposableMultipeerConnectivity"]),
    ]
)
