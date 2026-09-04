//
//  TransitLine.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 9/3/26.
//

/// A single transit route, belonging to a ``TransitNetwork``. References its
/// network and endpoint stops by ID rather than embedding their full values —
/// look them up through a data provider (e.g. a `TransitDataProvider`) when
/// the full object is needed.
public struct TransitLine: Identifiable, Sendable, Hashable {
    public typealias ID = String

    public let id: ID
    public let name: String
    public let networkID: TransitNetwork.ID
    public let routeNumber: String
    public let transportMode: TransportMode
    public let originStopID: TransitStop.ID
    public let terminusStopID: TransitStop.ID

    public init(
        id: ID,
        name: String,
        networkID: TransitNetwork.ID,
        routeNumber: String,
        transportMode: TransportMode,
        originStopID: TransitStop.ID,
        terminusStopID: TransitStop.ID
    ) {
        self.id = id
        self.name = name
        self.networkID = networkID
        self.routeNumber = routeNumber
        self.transportMode = transportMode
        self.originStopID = originStopID
        self.terminusStopID = terminusStopID
    }
}
