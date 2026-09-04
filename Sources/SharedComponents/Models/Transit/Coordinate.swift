//
//  Coordinate.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 9/3/26.
//

import CoreLocation

/// A latitude/longitude pair. Exists because `CLLocationCoordinate2D`
/// conforms to neither `Equatable` nor `Hashable`, which would otherwise
/// force every model that stores a location (e.g. ``TransitStop``) to
/// hand-write field-by-field `==`/`hash(into:)` implementations.
public struct Coordinate: Sendable, Hashable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    public var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
