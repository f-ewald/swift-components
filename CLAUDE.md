# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Build the package
swift build

# Run tests
swift test

# Run a single test
swift test --filter UIComponentsTests/testName
```

## Architecture

This is a Swift Package (swift-tools-version 6.2) targeting iOS 18+, macOS 15+, and watchOS 11+ — the lowest versions that support every API in use (notably `Color.mix`, introduced in iOS 18/macOS 15/watchOS 11). `WizardView`'s Liquid Glass button style is gated behind `#available(iOS 26, macOS 26, watchOS 26, *)` with a `.borderedProminent` fallback, so the package doesn't require 26 even though it adopts 26-only APIs where available. It uses SwiftUI exclusively and produces two libraries:

- **SharedComponents** — Platform-agnostic SwiftUI views. No UIKit dependency. Organized into `Models/`, `Services/`, `Views/` (e.g. `ErrorView`, `HeroView`, `LogoVersionView`, `PowerUserView`, `RatingsView`, `StatusBannerView`, `TipOfTheDayView`), and `Resources/` (color assets in `Colors.xcassets`). `CloudSettings.swift` lives at the target root.
- **UIComponents** — iOS/macOS SwiftUI views and utilities. Contains components that may use `#if canImport(UIKit)` for platform-specific code (e.g., shake detection). Organized into subdirectories by feature (`Feedback/`, `Wizard/`, `ShakeDetection/`); `SemVer.swift` lives at the target root.

Tests live in `UIComponentsTests` and depend on both libraries. The test target uses Swift Testing (`import Testing`, `@Test`), not XCTest.

`Tools/` is its own Swift package (its own `Package.swift`, depending on the root package via a local path dependency), not part of the root package's target graph, holding dev-only executables: `GenerateScreenshots` renders each documented view to a PNG for the README, and `ComponentDocsServer` is a stdio MCP server exposing `list_components`/`get_component_docs` so agents can discover "which component, and when" without grepping the package by hand. Run them with `swift run --package-path Tools GenerateScreenshots` / `swift run --package-path Tools ComponentDocsServer`. Tools/ is split out specifically so Xcode never has to resolve an executable target while Canvas-previewing a SharedComponents/UIComponents view — an executable target sharing a package graph with previewable SwiftUI code breaks Canvas (missing `AppKit` on non-macOS preview destinations, and/or "Previewing in executable targets ... requires `ENABLE_DEBUG_DYLIB`"). CI builds it as a separate step (`swift build --package-path Tools`) since root's `swift build`/`swift test` no longer touch it.

`ComponentDocsServer`'s docs are a merge of two sources, done in `Sources/ComponentDocsCore` (a library target in the *root* package — not Tools/ — so `UIComponentsTests` can depend on it directly without pulling in Tools/'s executables; the root package exposes it as a product so Tools/ComponentDocsServer can consume it back across the package boundary): SwiftSyntax-based scanning of `Sources/*` for public `View` types + public `init` signatures (can't drift, since it reads real source), and README.md's existing per-component `##`/`###`/`####` sections (hand-authored prose + usage example, reused rather than duplicated). `UIComponentsTests/ComponentDocsCoverageTests.swift` fails if a public View has no matching README section, which is what keeps that pairing honest — so a new component's README section is not optional, it's required for `swift test` to pass.

## Conventions

- Views use SwiftUI `#Preview` macros for previewing.
- Platform-conditional code uses `#if canImport(UIKit)` guards.
- Public API types require explicit `public init` since the package uses strict access control.
- Swift 6 strict concurrency is enabled — public types conform to `Sendable`. Use `@unchecked Sendable` only when necessary (e.g., mutable test doubles).
- Tests use Swift Testing assertions (`#expect`, `#require`) and `@Test` functions, not XCTest `XCTAssert`. Use `@testable import` to access internal types.
