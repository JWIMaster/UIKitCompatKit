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
        // Add GPUImage1Swift as a dependency
        .package(url: "https://github.com/JWIMaster/GPUImage1Swift.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "UIKitCompatKit",
            dependencies: ["OAStackView", "GPUImage1Swift", "LiveFrost"],
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
