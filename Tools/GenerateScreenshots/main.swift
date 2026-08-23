//
//  main.swift
//  GenerateScreenshots
//
//  Renders each documented view to a PNG under docs/screenshots for the README.
//  Not part of any library product — run locally with `swift run GenerateScreenshots`
//  whenever a documented view's appearance changes.
//
//  Uses @testable import to construct WizardStep/SemVer, which are internal types
//  only reachable through WizardService in normal (non-testable) consumer code.

import SharedComponents
import SwiftUI
@testable import UIComponents

// This tool is macOS-only (it uses AppKit to render offscreen windows for
// screenshots). Guarded so the package's module graph still resolves when
// Xcode builds for iOS/watchOS destinations — e.g. Canvas previews of
// SharedComponents/UIComponents views — which otherwise fails with
// "Unable to resolve module dependency: 'AppKit'" against this target.
#if os(macOS)
import AppKit

private let outputDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()  // main.swift -> GenerateScreenshots/
    .deletingLastPathComponent()  // -> Tools/
    .deletingLastPathComponent()  // -> repo root
    .appendingPathComponent("docs/screenshots")

@MainActor
private func renderPNG<V: View>(_ view: V, size: CGSize, scale: CGFloat = 3) -> Data? {
    let renderer = ImageRenderer(
        content:
            view
            .frame(width: size.width, height: size.height)
    )
    renderer.scale = scale
    guard let nsImage = renderer.nsImage,
        let tiffData = nsImage.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData)
    else { return nil }
    return bitmap.representation(using: .png, properties: [:])
}

@MainActor
private func save(_ name: String, size: CGSize, @ViewBuilder view: () -> some View) {
    guard let data = renderPNG(view(), size: size) else {
        print("⚠️  Failed to render \(name)")
        return
    }
    let url = outputDirectory.appendingPathComponent("\(name).png")
    do {
        try data.write(to: url)
        print("Wrote \(url.path)")
    } catch {
        print("⚠️  Failed to write \(name): \(error)")
    }
}

/// `ImageRenderer` doesn't reliably draw interactive AppKit-backed controls
/// (`TextField`, `Picker`, multi-line text editors) without a real responder
/// chain — it produces a "content unavailable" glyph instead. Hosting the view
/// in an actual (offscreen) window and using `cacheDisplay` renders correctly.
@MainActor
private func saveViaWindow(_ name: String, size: CGSize, @ViewBuilder view: () -> some View) {
    let hostingView = NSHostingView(rootView: view().frame(width: size.width, height: size.height))
    hostingView.frame = CGRect(origin: .zero, size: size)

    let window = NSWindow(
        contentRect: CGRect(x: -20000, y: -20000, width: size.width, height: size.height),
        styleMask: [.borderless],
        backing: .buffered,
        defer: false
    )
    window.isReleasedWhenClosed = false
    window.contentView = hostingView
    window.orderFrontRegardless()

    // Give the hosting view one run-loop pass to lay out and draw.
    RunLoop.main.run(until: Date().addingTimeInterval(0.1))

    guard let bitmap = hostingView.bitmapImageRepForCachingDisplay(in: hostingView.bounds) else {
        window.orderOut(nil)
        print("⚠️  Failed to render \(name)")
        return
    }
    hostingView.cacheDisplay(in: hostingView.bounds, to: bitmap)
    window.orderOut(nil)

    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        print("⚠️  Failed to encode \(name)")
        return
    }
    let url = outputDirectory.appendingPathComponent("\(name).png")
    do {
        try data.write(to: url)
        print("Wrote \(url.path)")
    } catch {
        print("⚠️  Failed to write \(name): \(error)")
    }
}

// MARK: - Demo compositions

private struct StatusBannerDemo: View {
    var body: some View {
        VStack(spacing: 12) {
            StatusBannerView(
                title: "Connection Error",
                message: "Could not reach the server. Please check your internet connection.",
                style: .error,
                isVisible: .constant(true)
            )
            StatusBannerView(
                title: "Service Alert",
                message: "Weekend schedule in effect. Trains run every 60 minutes.",
                style: .info,
                isVisible: .constant(true)
            )
        }
        .padding()
        .background(Color.white)
    }
}

@MainActor
private func run() {
    // Named colors from Colors.xcassets don't resolve reliably in a bare CLI
    // process without an active NSApplication (CoreUI/asset-catalog loading
    // quirk) — activate one before rendering anything that uses them.
    _ = NSApplication.shared
    NSApplication.shared.setActivationPolicy(.accessory)

    try? FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

    save("HeroView", size: CGSize(width: 320, height: 220)) {
        HeroView(
            title: "Track Your Progress",
            systemName: "chart.line.uptrend.xyaxis",
            description: "See your trends over time and celebrate every milestone."
        )
        .background(Color.white)
    }

    save("LogoVersionView", size: CGSize(width: 280, height: 90)) {
        LogoVersionView {
            Image(systemName: "cube.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundStyle(.blue)
        }
        .padding()
        .background(Color.white)
    }

    save("PowerUserView", size: CGSize(width: 280, height: 140)) {
        PowerUserView(appName: "MyApp")
            .background(Color.white)
    }

    save("StatusBannerView", size: CGSize(width: 340, height: 200)) {
        StatusBannerDemo()
    }

    save("TipOfTheDayView", size: CGSize(width: 320, height: 140)) {
        TipOfTheDayView(
            message: "Swipe left on any item to reveal quick actions.",
            isVisible: .constant(true)
        )
        .padding()
        .background(Color(white: 0.95))
    }

    saveViaWindow("FeedbackView", size: CGSize(width: 380, height: 420)) {
        FeedbackView(onSend: { _ in })
    }

    let wizardSteps = [
        WizardStep(
            title: "Feedback",
            subtitle: "Shake your phone to provide feedback",
            imageName: "bubble.circle",
            buttonLabel: "Next",
            version: SemVer(1, 0, 0)
        ),
        WizardStep(
            title: "You're all set!",
            subtitle: "Let's get started",
            imageName: "checkmark.seal.fill",
            buttonLabel: "Done",
            version: SemVer(1, 0, 0)
        ),
    ]
    save("WizardView", size: CGSize(width: 300, height: 460)) {
        WizardView(steps: wizardSteps) {}
            .background(Color.white)
    }

    save("Amenities", size: CGSize(width: 260, height: 60)) {
        Amenities(
            parkingSpaces: 42,
            bikeRacks: 12,
            hasRestrooms: true,
            hasElevator: true
        )
        .padding()
        .background(Color.white)
    }

    save("TransitIcons", size: CGSize(width: 220, height: 60)) {
        HStack {
            BikeIcon()
            ParkingIcon()
            RestroomIcon()
        }
        .padding()
        .background(Color.white)
    }

    save("ZoneTextView", size: CGSize(width: 140, height: 60)) {
        ZoneTextView(zone: 2)
            .padding()
            .background(Color.white)
    }

    save("TrainLogo", size: CGSize(width: 180, height: 180)) {
        TrainLogo(size: 140, color: .red)
            .padding()
            .background(Color.white)
    }

    print("Done.")
}

run()
#else
print("GenerateScreenshots only runs on macOS.")
#endif
