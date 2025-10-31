// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "UIKitCompatKit",
    platforms: [
        .iOS("7.0")
    ],
    products: [
        .library(
            name: "UIKitCompatKit",
            targets: ["UIKitCompatKit"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "UIKitCompatKit",
            dependencies: ["OAStackView", "LiveFrost"],
            path: "Sources/UIKitCompatKit"
        ),
        .target(
            name: "OAStackView",
            path: "Sources/OAStackView",
            publicHeadersPath: "."
        ),
        .target(
            name: "LiveFrost",
            path: "Sources/LiveFrost",
            publicHeadersPath: "."
        ),
        .testTarget(
            name: "UIKitCompatKitTests",
            dependencies: ["UIKitCompatKit"]
        ),
    ]
)
