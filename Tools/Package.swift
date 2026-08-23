// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// A separate package from the root one (../Package.swift) on purpose: these
// are macOS-only dev tools, not part of any product. Kept out of the root
// package's own target graph so Xcode never has to resolve an executable
// target while previewing a SharedComponents/UIComponents view — an
// executable target in the same graph as previewable SwiftUI code breaks
// Canvas (missing AppKit on non-macOS preview destinations, and/or "Previewing
// in executable targets ... requires ENABLE_DEBUG_DYLIB").
let package = Package(
    name: "SwiftComponentsTools",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.11.0"),
    ],
    targets: [
        // Renders each documented view to a PNG under docs/screenshots for the
        // README. Run with `swift run --package-path Tools GenerateScreenshots`
        // whenever a documented view's appearance changes.
        .executableTarget(
            name: "GenerateScreenshots",
            dependencies: [
                .product(name: "SharedComponents", package: "swift-components"),
                .product(name: "UIComponents", package: "swift-components"),
            ],
            path: "GenerateScreenshots"
        ),
        // MCP server exposing swift-components' public Views to agents:
        // `list_components` / `get_component_docs`. Run with
        // `swift run --package-path Tools ComponentDocsServer` (stdio transport).
        .executableTarget(
            name: "ComponentDocsServer",
            dependencies: [
                .product(name: "ComponentDocsCore", package: "swift-components"),
                .product(name: "MCP", package: "swift-sdk"),
            ],
            path: "ComponentDocsServer"
        ),
    ]
)
