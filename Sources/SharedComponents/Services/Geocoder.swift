//
//  Geocoder.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 8/22/26.
//

import CoreLocation

/// Abstracts reverse geocoding so ``Geocoder`` can be tested without a real `CLGeocoder`.
public protocol GeocodingProviding: Sendable {
    func reverseGeocodeLocation(_ location: CLLocation) async throws -> [Address]
}

/// Wraps `CLGeocoder`, mapping its `CLPlacemark` results to ``Address``.
///
/// A fresh `CLGeocoder` is created per call rather than reused, since a single
/// `CLGeocoder` instance cancels its own in-flight request when a new one is
/// started on it — reusing one would break concurrent ``Geocoder`` calls.
public struct SystemGeocodingProvider: GeocodingProviding {
    public init() {}

    public func reverseGeocodeLocation(_ location: CLLocation) async throws -> [Address] {
        let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
        return placemarks.map { placemark in
            Address(
                name: placemark.name,
                thoroughfare: placemark.thoroughfare,
                locality: placemark.locality,
                administrativeArea: placemark.administrativeArea,
                postalCode: placemark.postalCode,
                country: placemark.country,
                isoCountryCode: placemark.isoCountryCode
            )
        }
    }
}

/// Errors thrown by ``Geocoder``.
public enum GeocoderError: Error, Equatable, Sendable {
    /// The geocoding provider returned no results for the given coordinate.
    case noResults
}

/// A stateless wrapper around reverse geocoding, returning a plain ``Address``
/// instead of `CLPlacemark`.
public struct Geocoder: Sendable {
    private let provider: any GeocodingProviding

    public init(provider: any GeocodingProviding = SystemGeocodingProvider()) {
        self.provider = provider
    }

    /// Reverse geocodes `coordinate` into an ``Address``.
    ///
    /// - Throws: ``GeocoderError/noResults`` if no address could be found, or
    ///   an underlying error from the geocoding provider.
    public func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> Address {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let addresses = try await provider.reverseGeocodeLocation(location)
        guard let address = addresses.first else {
            throw GeocoderError.noResults
        }
        return address
    }
}
