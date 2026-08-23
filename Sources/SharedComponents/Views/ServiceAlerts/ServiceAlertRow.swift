//
//  ServiceAlertRow.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 8/22/26.
//

import SwiftUI

/// A single service alert row: severity icon, header, and severity badge.
public struct ServiceAlertRow: View {
    let alert: ServiceAlert

    public init(alert: ServiceAlert) {
        self.alert = alert
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: alert.severity.iconName)
                .foregroundStyle(alert.severity.color)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(alert.header)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                Text(alert.severity.label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(alert.severity.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(alert.severity.color.opacity(0.15))
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(alert.severity.color.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Previews

#Preview {
    List {
        ServiceAlertRow(alert: ServiceAlert(
            id: "1",
            severity: .disruption,
            header: "Delayed: Train 114 southbound is running about 30 minutes late.",
            description: "The following stops may also be affected: Palo Alto."
        ))
        ServiceAlertRow(alert: ServiceAlert(
            id: "2",
            severity: .warning,
            header: "Accessibility: Southbound elevator out of service at Bayshore.",
            description: ""
        ))
    }
}
