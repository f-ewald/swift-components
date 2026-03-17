//
//  StatusBannerView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/17/26.
//

import SwiftUI

/// The visual style of a ``StatusBannerView``, indicating its severity.
public enum StatusBannerStyle: Sendable {
    /// A prominent red banner for critical errors (e.g., server connection failure).
    case error
    /// A calmer amber banner for informational alerts (e.g., Caltrain service alerts).
    case info
}

/// An inline banner view that displays error messages or informational alerts.
///
/// `StatusBannerView` is designed to be placed inside a `List` and supports two
/// visual styles: `.error` for critical failures and `.info` for service alerts.
/// It automatically adapts to light and dark mode.
///
/// ```swift
/// List {
///     StatusBannerView(
///         title: "Connection Error",
///         message: "Could not reach the server.",
///         style: .error,
///         isVisible: $showError
///     )
///
///     StatusBannerView(
///         title: "Service Alert",
///         message: "Weekend schedule in effect.",
///         style: .info,
///         isVisible: $showAlert,
///         isDismissable: false
///     )
/// }
/// ```
public struct StatusBannerView: View {
    let title: String
    let message: String?
    let style: StatusBannerStyle
    @Binding var isVisible: Bool
    let isDismissable: Bool

    /// Creates a new status banner.
    /// - Parameters:
    ///   - title: The bold headline text.
    ///   - message: An optional detail message shown below the title.
    ///   - style: The visual style (`.error` or `.info`).
    ///   - isVisible: A binding that controls the banner's visibility.
    ///   - isDismissable: Whether a close button is shown. Defaults to `true`.
    public init(
        title: String,
        message: String? = nil,
        style: StatusBannerStyle,
        isVisible: Binding<Bool>,
        isDismissable: Bool = true
    ) {
        self.title = title
        self.message = message
        self.style = style
        self._isVisible = isVisible
        self.isDismissable = isDismissable
    }

    public var body: some View {
        if isVisible {
            HStack(alignment: .top, spacing: 0) {
                // Colored left accent bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor)
                    .frame(width: 4)
                    .padding(.vertical, 4)

                // Icon
                Image(systemName: iconName)
                    .foregroundStyle(accentColor)
                    .font(.body)
                    .padding(.leading, 10)
                    .padding(.top, 2)

                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    if let message {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.leading, 8)

                Spacer(minLength: 4)

                // Dismiss button
                if isDismissable {
                    Button {
                        withAnimation(.spring()) {
                            isVisible = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(6)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Dismiss")
                    .accessibilityIdentifier("statusBannerDismiss")
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .top)),
                removal: .opacity.combined(with: .scale(scale: 0.95))
            ))
        }
    }

    // MARK: - Style Helpers

    private var accentColor: Color {
        switch style {
        case .error:
            Color("StatusBannerErrorAccent", bundle: .module)
        case .info:
            Color("StatusBannerInfoAccent", bundle: .module)
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .error:
            Color("StatusBannerErrorBackground", bundle: .module)
        case .info:
            Color("StatusBannerInfoBackground", bundle: .module)
        }
    }

    private var iconName: String {
        switch style {
        case .error:
            "exclamationmark.triangle.fill"
        case .info:
            "info.circle.fill"
        }
    }
}

// MARK: - Previews

#Preview("Error - Light") {
    @Previewable @State var isVisible = true
    List {
        StatusBannerView(
            title: "Connection Error",
            message: "Could not reach the server. Please check your internet connection and try again.",
            style: .error,
            isVisible: $isVisible
        )

        Text("Station 1")
        Text("Station 2")
    }
}

#Preview("Error - Dark") {
    @Previewable @State var isVisible = true
    List {
        StatusBannerView(
            title: "Connection Error",
            message: "Could not reach the server. Please check your internet connection and try again.",
            style: .error,
            isVisible: $isVisible
        )

        Text("Station 1")
        Text("Station 2")
    }
    .preferredColorScheme(.dark)
}

#Preview("Info - Light") {
    @Previewable @State var isVisible = true
    List {
        StatusBannerView(
            title: "Service Alert",
            message: "Weekend schedule in effect. Trains run every 60 minutes.",
            style: .info,
            isVisible: $isVisible
        )
        Text("Station 1")
        Text("Station 2")
    }
}

#Preview("Info - Dark") {
    @Previewable @State var isVisible = true
    List {
        StatusBannerView(
            title: "Service Alert",
            message: "Weekend schedule in effect. Trains run every 60 minutes.",
            style: .info,
            isVisible: $isVisible
        )
        Text("Station 1")
        Text("Station 2")
    }
    .preferredColorScheme(.dark)
}

#Preview("Non-Dismissable") {
    @Previewable @State var isVisible = true
    List {
        StatusBannerView(
            title: "Service Alert",
            message: "Track maintenance between San Jose and Sunnyvale.",
            style: .info,
            isVisible: $isVisible,
            isDismissable: false
        )
        Text("Station 1")
    }
}

#Preview("Title Only") {
    @Previewable @State var isVisible = true
    List {
        StatusBannerView(
            title: "No internet connection",
            style: .error,
            isVisible: $isVisible
        )
    }
}

#Preview("Both Styles") {
    @Previewable @State var showError = true
    @Previewable @State var showAlert = true
    List {
        StatusBannerView(
            title: "Connection Error",
            message: "Could not reach the server.",
            style: .error,
            isVisible: $showError
        )
        .listRowInsets(.none)
        .listRowSeparator(.hidden)

        StatusBannerView(
            title: "Service Alert",
            message: "Weekend schedule in effect.",
            style: .info,
            isVisible: $showAlert
        )

        Text("Station 1")
        Text("Station 2")
        Text("Station 3")
    }
}
