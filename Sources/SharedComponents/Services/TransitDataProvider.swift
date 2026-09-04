//
//  TransitDataProvider.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 9/3/26.
//

import CoreLocation

/// Abstraction over a single transit agency's data source (static schedule
/// data plus real-time departures/alerts). This package ships no concrete
/// implementation — each host app supplies one backed by whatever API/GTFS
/// feed its agency exposes, and resolves the ID references used throughout
/// ``TransitStop``/``TransitLine``/``TransitNetwork`` through it.
public protocol TransitDataProvider: Sendable {
    func network(id: TransitNetwork.ID) async throws -> TransitNetwork
    func stop(id: TransitStop.ID) async throws -> TransitStop
    func line(id: TransitLine.ID) async throws -> TransitLine

    /// Stops within `radius` meters of `coordinate`, nearest first.
    func nearbyStops(to coordinate: Coordinate, radius: CLLocationDistance) async throws -> [TransitStop]

    /// Upcoming departures from `stopID`, soonest first, capped at `limit`.
    func departures(from stopID: TransitStop.ID, limit: Int) async throws -> [Departure]

    /// Active service alerts affecting `stopID`.
    func alerts(for stopID: TransitStop.ID) async throws -> [ServiceAlert]
}
