// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [.iOS(.v26), .macOS(.v26), .watchOS(.v26), .tvOS(.v26), .visionOS(.v26)],
    products: [
        .library(name: "Network", targets: ["Network"]),
    ],
    targets: [
        .target(
            name: "Network",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "NetworkTests",
            dependencies: ["Network"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
