//
//  TransitStop.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 9/3/26.
//

public enum OperationalState: Sendable, Hashable {
    case normal, limited, outOfService, unknown
}

/// Accessibility features present at a ``TransitStop``.
public enum Accessibility: Sendable, Hashable {
    case wheelchairAccessible, elevator, escalator
}

/// Represents a station or stop served by transit. References the lines that
/// stop here by ID rather than embedding their full values — a line's
/// origin/terminus are themselves stops, so embedding full values would
/// require each stop and its lines to already exist to construct one
/// another. Look lines up through a data provider (e.g. a
/// `TransitDataProvider`) when the full object is needed.
public struct TransitStop: Identifiable, Sendable, Hashable, CustomStringConvertible {
    public typealias ID = String

    public let id: ID
    public let name: String
    public let coordinate: Coordinate
    public let operationalState: OperationalState
    public let accessibility: Set<Accessibility>
    /// Fare zone, for systems with zone-based fares (e.g. ``ZoneTextView``). `nil` if the network is flat-fare.
    public let zone: Int?
    public let lineIDs: [TransitLine.ID]

    public init(
        id: ID,
        name: String,
        coordinate: Coordinate,
        operationalState: OperationalState,
        accessibility: Set<Accessibility> = [],
        zone: Int? = nil,
        lineIDs: [TransitLine.ID] = []
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.operationalState = operationalState
        self.accessibility = accessibility
        self.zone = zone
        self.lineIDs = lineIDs
    }

    public var hasElevator: Bool { accessibility.contains(.elevator) }
    public var hasEscalator: Bool { accessibility.contains(.escalator) }

    public var description: String {
        "\(String(describing: Self.self))(name: \(name), lines: \(lineIDs.count), coordinate: \(coordinate), operationalState: \(operationalState))"
    }
}
