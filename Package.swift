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
        // Exposed so the Tools/ package (a separate package — see its own
        // Package.swift) can consume it as a local dependency for
        // ComponentDocsServer, without this root package needing to know
        // about Tools/ at all.
        .library(
            name: "ComponentDocsCore",
            targets: ["ComponentDocsCore"]
        ),
    ],
    dependencies: [
        // Needed by the ComponentDocsCore target below to scan SharedComponents/
        // UIComponents source for public Views. SharedComponents/UIComponents
        // themselves stay dependency-free.
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
        // Scans SharedComponents/UIComponents source for public Views and merges
        // it with README.md's hand-authored prose/examples. Shared by
        // Tools/ComponentDocsServer (a separate package) and by
        // UIComponentsTests' doc-coverage check. Lives here, rather than in
        // Tools/, so this root package's own graph never includes an
        // executable target — see Tools/Package.swift for why that matters.
        .target(
            name: "ComponentDocsCore",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ],
            path: "Sources/ComponentDocsCore"
        ),
    ]
)
