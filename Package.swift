// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .watchOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SharedComponents",
            targets: ["SharedComponents"]
        ),
        .library(
            name: "UIComponents",
            targets: ["UIComponents"]
        ),
    ],
    dependencies: [
        // Only pulled in by the Tools/ComponentDocsServer target below —
        // SharedComponents/UIComponents themselves stay dependency-free.
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.11.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SharedComponents",
            path: "Sources/SharedComponents",
            resources: [.process("Resources")]
        ),
        .target(
            name: "UIComponents",
            path: "Sources/UIComponents"
        ),
        .testTarget(
            name: "UIComponentsTests",
            dependencies: ["UIComponents", "SharedComponents", "ComponentDocsCore"]
        ),
        // Internal tool (macOS-only, not part of any product) that renders each
        // documented view to a PNG for README screenshots. Run with `swift run GenerateScreenshots`.
        .executableTarget(
            name: "GenerateScreenshots",
            dependencies: ["UIComponents", "SharedComponents"],
            path: "Tools/GenerateScreenshots"
        ),
        // Scans SharedComponents/UIComponents source for public Views and merges
        // it with README.md's hand-authored prose/examples. Shared by the MCP
        // server below and by UIComponentsTests' doc-coverage check.
        .target(
            name: "ComponentDocsCore",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ],
            path: "Tools/ComponentDocsCore"
        ),
        // MCP server exposing swift-components' public Views to agents:
        // `list_components` / `get_component_docs`. Run with
        // `swift run ComponentDocsServer` (stdio transport).
        .executableTarget(
            name: "ComponentDocsServer",
            dependencies: [
                "ComponentDocsCore",
                .product(name: "MCP", package: "swift-sdk"),
            ],
            path: "Tools/ComponentDocsServer"
        ),
    ]
)
