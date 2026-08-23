//
//  ServiceAlertRow.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 8/22/26.
//

import SwiftUI

/// A single service alert row: severity icon, header, severity badge, and — when
/// `alert.tags` is non-empty — a sparkles-prefixed row of classification tag pills.
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

                if !alert.tags.isEmpty {
                    FlowLayout(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        ForEach(alert.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.secondary.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(alert.severity.color.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - FlowLayout

/// A minimal left-to-right, top-to-bottom wrapping layout for tag pills.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > width, rowWidth > 0 {
                totalHeight += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight

        return CGSize(width: width == .infinity ? rowWidth : width, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let width = bounds.width

        // Group subviews into rows first so each row's items can be vertically
        // centered against that row's tallest item (e.g. the sparkles icon next
        // to taller tag pills), rather than all sharing a single top edge.
        var rows: [[Int]] = [[]]
        var rowWidths: [CGFloat] = [0]
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidths[rows.count - 1] + size.width > width, rowWidths[rows.count - 1] > 0 {
                rows.append([])
                rowWidths.append(0)
            }
            rows[rows.count - 1].append(index)
            rowWidths[rows.count - 1] += size.width + spacing
        }

        var y = bounds.minY
        for row in rows {
            let sizes = row.map { subviews[$0].sizeThatFits(.unspecified) }
            let rowHeight = sizes.map(\.height).max() ?? 0
            var x = bounds.minX
            for (rowIndex, subviewIndex) in row.enumerated() {
                let size = sizes[rowIndex]
                let yOffset = (rowHeight - size.height) / 2
                subviews[subviewIndex].place(at: CGPoint(x: x, y: y + yOffset), anchor: .topLeading, proposal: .unspecified)
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }
}

// MARK: - Previews

#Preview {
    List {
        ServiceAlertRow(alert: ServiceAlert(
            id: "1",
            severity: .disruption,
            header: "Delayed: Train 114 southbound is running about 30 minutes late.",
            description: "The following stops may also be affected: Palo Alto.",
            tags: ["Train 114", "Delay"]
        ))
        ServiceAlertRow(alert: ServiceAlert(
            id: "2",
            severity: .warning,
            header: "Accessibility: Southbound elevator out of service at Bayshore.",
            description: ""
        ))
    }
}
