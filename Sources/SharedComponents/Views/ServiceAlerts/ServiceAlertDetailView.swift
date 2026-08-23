//
//  ServiceAlertDetailView.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 8/22/26.
//

import SwiftUI

/// Full detail content for a single ``ServiceAlert``. Carries no navigation
/// chrome of its own (no title, no bar) — the host app supplies that,
/// whether it's pushed (`.navigationTitle`) or presented as a sheet
/// (pass `onDismiss` to get a close button).
public struct ServiceAlertDetailView: View {
    let alert: ServiceAlert
    let onDismiss: (() -> Void)?

    public init(alert: ServiceAlert, onDismiss: (() -> Void)? = nil) {
        self.alert = alert
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let onDismiss {
                    HStack {
                        Spacer()
                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Label(alert.severity.label, systemImage: alert.severity.iconName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(alert.severity.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(alert.severity.color.opacity(0.12))
                    .clipShape(Capsule())

                Text(alert.header).font(.headline)

                if !alert.description.isEmpty {
                    Text(alert.description).font(.body).foregroundStyle(.secondary)
                }

                if let url = alert.url {
                    Link(destination: url) {
                        HStack {
                            Text("More Information")
                            Image(systemName: "arrow.up.right").font(.caption)
                        }
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Previews

#Preview("Pushed (no dismiss button)") {
    ServiceAlertDetailView(alert: ServiceAlert(
        id: "1",
        severity: .disruption,
        header: "Delayed: Train 114 southbound is running about 30 minutes late.",
        description: "The following stops may also be affected: Palo Alto.",
        url: URL(string: "https://www.caltrain.com")
    ))
}

#Preview("Sheet (with dismiss button)") {
    ServiceAlertDetailView(
        alert: ServiceAlert(
            id: "2",
            severity: .warning,
            header: "Accessibility: Southbound elevator out of service at Bayshore.",
            description: ""
        ),
        onDismiss: {}
    )
}
