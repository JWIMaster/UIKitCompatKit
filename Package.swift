// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription

let package = Package(
    name: "UIKitCompatKit",
    platforms: [
        .iOS("7.0") // set minimum iOS you want to support
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "UIKitCompatKit",
            targets: ["UIKitCompatKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Swift target
        .target(
            name: "UIKitCompatKit",
            dependencies: ["OAStackView"],
            path: "Sources/UIKitCompatKit"
        ),
        
        // Objective-C target for OAStackView
        .target(
            name: "OAStackView",
            path: "Sources/OAStackView",
            publicHeadersPath: "."
        ),
        .target(
            name: "UIStackView",
            dependencies: ["OAStackView"],
            path: "Sources/UIStackView"
        ),
        
            .testTarget(
                name: "UIKitCompatKitTests",
                dependencies: ["UIKitCompatKit"]
            )
    ]
    
)

