//
//  ServiceAlert.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 8/22/26.
//

import SwiftUI

/// Severity of a ``ServiceAlert``, driving its color/icon/label wherever it's displayed.
public enum ServiceAlertSeverity: Sendable {
    /// A critical disruption — no service, significant delays, accident, strike, medical emergency.
    case disruption
    /// A non-critical issue — minor delays, reduced service, detour, accessibility issue.
    case warning

    public var color: Color {
        switch self {
        case .disruption: .red
        case .warning: .orange
        }
    }

    public var iconName: String {
        switch self {
        case .disruption: "xmark.octagon.fill"
        case .warning: "exclamationmark.triangle.fill"
        }
    }

    public var label: String {
        switch self {
        case .disruption: "Disruption"
        case .warning: "Warning"
        }
    }
}

/// A single transit service alert, agnostic of the API/feed format it was decoded from.
public struct ServiceAlert: Identifiable, Sendable {
    public let id: String
    public let severity: ServiceAlertSeverity
    public let header: String
    public let description: String
    public let url: URL?

    public init(
        id: String,
        severity: ServiceAlertSeverity,
        header: String,
        description: String,
        url: URL? = nil
    ) {
        self.id = id
        self.severity = severity
        self.header = header
        self.description = description
        self.url = url
    }
}
