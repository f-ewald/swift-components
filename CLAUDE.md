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

This is a Swift Package (swift-tools-version 6.2) targeting iOS 26+, macOS 26+, and watchOS 26+. It uses SwiftUI exclusively and produces two libraries:

- **SharedComponents** — Platform-agnostic SwiftUI views. No UIKit dependency. Organized into `Models/`, `Services/`, `Views/` (e.g. `ErrorView`, `HeroView`, `LogoVersionView`, `PowerUserView`, `RatingsView`, `StatusBannerView`, `TipOfTheDayView`), and `Resources/` (color assets in `Colors.xcassets`). `CloudSettings.swift` lives at the target root.
- **UIComponents** — iOS/macOS SwiftUI views and utilities. Contains components that may use `#if canImport(UIKit)` for platform-specific code (e.g., shake detection). Organized into subdirectories by feature (`Feedback/`, `Wizard/`, `ShakeDetection/`); `SemVer.swift` lives at the target root.

Tests live in `UIComponentsTests` and depend on both libraries. The test target uses Swift Testing (`import Testing`, `@Test`), not XCTest.

## Conventions

- Views use SwiftUI `#Preview` macros for previewing.
- Platform-conditional code uses `#if canImport(UIKit)` guards.
- Public API types require explicit `public init` since the package uses strict access control.
- Swift 6 strict concurrency is enabled — public types conform to `Sendable`. Use `@unchecked Sendable` only when necessary (e.g., mutable test doubles).
- Tests use Swift Testing assertions (`#expect`, `#require`) and `@Test` functions, not XCTest `XCTAssert`. Use `@testable import` to access internal types.
