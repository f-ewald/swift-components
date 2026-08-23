//
//  AllServiceAlertsView.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 8/22/26.
//

import SwiftUI

/// A full scrollable list of every ``ServiceAlert``, for when there are more
/// than fit inline in a ``ServiceAlertsView``.
public struct AllServiceAlertsView: View {
    let alerts: [ServiceAlert]
    let onSelectAlert: (ServiceAlert) -> Void

    public init(alerts: [ServiceAlert], onSelectAlert: @escaping (ServiceAlert) -> Void) {
        self.alerts = alerts
        self.onSelectAlert = onSelectAlert
    }

    public var body: some View {
        List {
            ForEach(alerts) { alert in
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
        }
    }
}

// MARK: - Previews

#Preview {
    AllServiceAlertsView(
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
        onSelectAlert: { _ in }
    )
}
