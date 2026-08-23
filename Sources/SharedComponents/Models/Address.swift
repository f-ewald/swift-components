//
//  Address.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 8/22/26.
//

import Foundation

/// A postal address, mirroring the common fields of `CLPlacemark`, returned by ``Geocoder``.
public struct Address: Sendable, Hashable {
    public let name: String?
    public let thoroughfare: String?
    public let locality: String?
    public let administrativeArea: String?
    public let postalCode: String?
    public let country: String?
    public let isoCountryCode: String?

    public init(
        name: String? = nil,
        thoroughfare: String? = nil,
        locality: String? = nil,
        administrativeArea: String? = nil,
        postalCode: String? = nil,
        country: String? = nil,
        isoCountryCode: String? = nil
    ) {
        self.name = name
        self.thoroughfare = thoroughfare
        self.locality = locality
        self.administrativeArea = administrativeArea
        self.postalCode = postalCode
        self.country = country
        self.isoCountryCode = isoCountryCode
    }
}
