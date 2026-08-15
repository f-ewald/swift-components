# UIComponents

A Swift Package providing reusable SwiftUI components for iOS 18+, macOS 15+, and watchOS 11+. The package is split into two libraries:

- **SharedComponents** — Platform-agnostic views and utilities
- **UIComponents** — iOS/macOS-specific views (includes UIKit-dependent features)

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/UIComponents.git", from: "1.0.0")
]
```

Then add the libraries you need to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["SharedComponents", "UIComponents"]
)
```

## SharedComponents

### TipOfTheDayView

A dismissible tip card with a gradient background. Supports an optional auto-close timer that displays a circular countdown animation around the close button.

```swift
@State private var showTip = true

TipOfTheDayView(
    message: "Swipe left on any item to reveal quick actions.",
    isVisible: $showTip
)
```

With auto-close after 5 seconds:

```swift
TipOfTheDayView(
    message: "This tip will dismiss automatically.",
    isVisible: $showTip,
    autoCloseAfter: .seconds(5)
)
```

### CloudSettings / CloudStorage

A base class and property wrapper for syncing settings via iCloud key-value storage.

```swift
class MySettings: CloudSettings {
    @CloudStorage("theme", default: "light") var theme: String
    @CloudStorage("fontSize", default: 14) var fontSize: Int
}

struct SettingsView: View {
    @StateObject private var settings = MySettings()

    var body: some View {
        Picker("Theme", selection: $settings.theme) {
            Text("Light").tag("light")
            Text("Dark").tag("dark")
        }
    }
}
```

`CloudStorage` supports primitive types (`String`, `Int`, `Double`, `Bool`, `Data`) and `RawRepresentable` enums whose raw value is a plist type.

### LogoVersionView

Displays an app logo with the version and build number read from the main bundle.

```swift
// Using an image asset
LogoVersionView(logo: "AppIcon")

// Using a custom view
LogoVersionView {
    Image(systemName: "star.fill")
        .foregroundStyle(.yellow)
}
```

### RatingsView / AppLaunchState

Prompts for an App Store review after a set number of launches.

```swift
struct ContentView: View {
    @State private var appLaunchState = AppLaunchState()

    var body: some View {
        VStack {
            // Your content
        }
        .environment(appLaunchState)
        .overlay { RatingsView() }
        .onAppear { appLaunchState.launchCount += 1 }
    }
}
```

### PowerUserView

An easter-egg view that shows a pulsing heart animation with an appreciation message.

```swift
PowerUserView(appName: "MyApp")
```

### Error Alert

A view modifier for presenting error alerts from an optional string binding.

```swift
@State private var errorMessage: String?

VStack {
    Button("Do something") {
        errorMessage = "Something went wrong"
    }
}
.errorAlert(message: $errorMessage)
```

## UIComponents

### FeedbackView / FeedbackService

A feedback form with a 5-star rating and message field, plus an HTTP service for submitting feedback.

```swift
FeedbackView { feedback in
    let service = FeedbackService(
        url: URL(string: "https://api.example.com/feedback")!
    )
    try await service.send(feedback)
}
```

### Shake Detection (iOS only)

A view modifier that triggers an action when the user shakes the device.

```swift
Text("Shake to undo")
    .onShake {
        print("Device was shaken!")
    }
```

### WizardView

A multi-step onboarding wizard with step indicators and animated transitions.

## Requirements

- Swift 6.2+
- iOS 18+ / macOS 15+ / watchOS 11+

## Building & Testing

```bash
swift build
swift test
```
