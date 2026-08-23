//
//  ServiceAlertsView.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 8/22/26.
//

import SwiftUI

/// Displays up to `visibleCount` service alerts inline, with a "See all N
/// alerts" row when more exist. Carries no navigation of its own — splice it
/// directly into a `List`/`Section` or a plain `VStack`, and handle
/// `onSelectAlert`/`onShowAllAlerts` with whatever presentation (push, sheet,
/// etc.) fits the host app.
public struct ServiceAlertsView: View {
    let alerts: [ServiceAlert]
    let visibleCount: Int
    let onSelectAlert: (ServiceAlert) -> Void
    let onShowAllAlerts: () -> Void

    public init(
        alerts: [ServiceAlert],
        visibleCount: Int = 2,
        onSelectAlert: @escaping (ServiceAlert) -> Void,
        onShowAllAlerts: @escaping () -> Void
    ) {
        self.alerts = alerts
        self.visibleCount = max(0, visibleCount)
        self.onSelectAlert = onSelectAlert
        self.onShowAllAlerts = onShowAllAlerts
    }

    private var visible: [ServiceAlert] { Array(alerts.prefix(visibleCount)) }

    public var body: some View {
        ForEach(visible) { alert in
            Button {
                onSelectAlert(alert)
            } label: {
                ServiceAlertRow(alert: alert)
            }
            .buttonStyle(.plain)
            #if os(iOS) || os(macOS)
            .listRowSeparator(.hidden)
            #endif
        }

        if alerts.count > visibleCount {
            Button(action: onShowAllAlerts) {
                Text("See all \(alerts.count) alerts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            #if os(iOS) || os(macOS)
            .listRowSeparator(.hidden)
            #endif
        }
    }
}

// MARK: - Previews

#Preview("Two alerts, more available") {
    List {
        Section("Alerts") {
            ServiceAlertsView(
                alerts: [
                    ServiceAlert(
                        id: "1",
                        severity: .disruption,
                        header: "Delayed: Train 114 southbound is running about 30 minutes late.",
                        description: "The following stops may also be affected: Palo Alto."
                    ),
                    ServiceAlert(
                        id: "2",
                        severity: .warning,
                        header: "Accessibility: Southbound elevator out of service at Bayshore.",
                        description: ""
                    ),
                    ServiceAlert(
                        id: "3",
                        severity: .warning,
                        header: "Minor delays systemwide.",
                        description: ""
                    ),
                ],
                onSelectAlert: { _ in },
                onShowAllAlerts: {}
            )
        }
        Text("Station 1")
        Text("Station 2")
    }
}

#Preview("Single alert, no 'see all'") {
    List {
        Section("Alerts") {
            ServiceAlertsView(
                alerts: [
                    ServiceAlert(
                        id: "1",
                        severity: .warning,
                        header: "Minor delays systemwide.",
                        description: ""
                    )
                ],
                onSelectAlert: { _ in },
                onShowAllAlerts: {}
            )
        }
    }
}
