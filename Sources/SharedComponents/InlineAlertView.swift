//
//  InlineAlertView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/17/26.
//

import SwiftUI

public enum InlineAlertType {
    case info
    case warning
    case disruption

    var icon: String {
        switch self {
        case .info: "info.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .disruption: "bolt.horizontal.fill"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .info: [
            Color(hue: 0.58, saturation: 0.65, brightness: 0.95),
            Color(hue: 0.61, saturation: 0.50, brightness: 1.0)
        ]
        case .warning: [
            Color(hue: 0.09, saturation: 0.75, brightness: 1.0),
            Color(hue: 0.12, saturation: 0.60, brightness: 1.0)
        ]
        case .disruption: [
            Color(hue: 0.03, saturation: 0.70, brightness: 1.0),
            Color(hue: 0.06, saturation: 0.55, brightness: 1.0)
        ]
        }
    }

    var shadowColor: Color {
        switch self {
        case .info: .blue.opacity(0.25)
        case .warning: .orange.opacity(0.25)
        case .disruption: .red.opacity(0.20)
        }
    }
}

public struct InlineAlertView: View {
    let type: InlineAlertType
    let title: String
    let message: String
    @Binding var isVisible: Bool
    let isDismissible: Bool

    public init(
        type: InlineAlertType,
        title: String,
        message: String,
        isVisible: Binding<Bool>,
        isDismissible: Bool = true
    ) {
        self.type = type
        self.title = title
        self.message = message
        self._isVisible = isVisible
        self.isDismissible = isDismissible
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background gradient
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: type.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: type.shadowColor, radius: 12, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 6) {
                // Title
                Label {
                    Text(title)
                        .font(.headline)
                } icon: {
                    Image(systemName: type.icon)
                        .font(.system(size: 16))
                }
                .foregroundStyle(.black.opacity(0.75))

                // Message
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.black.opacity(0.65))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, isDismissible ? 20 : 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            // Close button
            if isDismissible {
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        isVisible = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.black.opacity(0.5), .black.opacity(0.15))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("inlineAlert.close")
                .padding(10)
                .sensoryFeedback(.success, trigger: isVisible)
            }
        }
        .padding(.horizontal, 0)
    }
}

#Preview("Inline Alerts") {
    @Previewable @State var showInfo: Bool = true
    @Previewable @State var showWarning: Bool = true
    @Previewable @State var showDisruption: Bool = true

    List {
        if showInfo {
            InlineAlertView(
                type: .info,
                title: "Service Update",
                message: "Piccadilly line running with minor delays between Cockfosters and Heathrow.",
                isVisible: $showInfo
            )
            .transition(.move(edge: .top).combined(with: .opacity))
            .listRowSeparator(.hidden)
        }

        if showWarning {
            InlineAlertView(
                type: .warning,
                title: "Weather Advisory",
                message: "Heavy rain expected this afternoon. Allow extra travel time.",
                isVisible: $showWarning
            )
            .transition(.move(edge: .top).combined(with: .opacity))
            .listRowSeparator(.hidden)
        }

        if showDisruption {
            InlineAlertView(
                type: .disruption,
                title: "Major Disruption",
                message: "Northern line suspended between Camden Town and Morden due to signal failure.",
                isVisible: $showDisruption
            )
            .transition(.move(edge: .top).combined(with: .opacity))
            .listRowSeparator(.hidden)
        }

        InlineAlertView(
            type: .info,
            title: "Permanent Notice",
            message: "This alert cannot be dismissed by the user.",
            isVisible: .constant(true),
            isDismissible: false
        )
        .listRowSeparator(.hidden)

        Button {
            showInfo = true
            showWarning = true
            showDisruption = true
        } label: {
            Text("Reset")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
    .animation(.spring(duration: 0.35), value: showInfo)
    .animation(.spring(duration: 0.35), value: showWarning)
    .animation(.spring(duration: 0.35), value: showDisruption)
}
