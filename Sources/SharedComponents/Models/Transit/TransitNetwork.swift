//
//  TransitNetwork.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 9/3/26.
//

import Foundation

public enum TransportMode: Sendable, Hashable {
    case bus, streetcar, train, subway, lightRail, monorail, ferry
}

public struct TransitNetwork: Identifiable, Sendable, Hashable, CustomStringConvertible {
    public typealias ID = String

    public let id: ID
    public let name: String
    public let homepage: URL
    /// Image/asset name the host app resolves from its own bundle. This
    /// package ships no per-agency logo assets, so the value is only ever a
    /// lookup key — resolving it to an actual image is the host app's job.
    public let logo: String
    public let transportModes: Set<TransportMode>

    public init(
        id: ID,
        name: String,
        homepage: URL,
        logo: String,
        transportModes: Set<TransportMode>
    ) {
        self.id = id
        self.name = name
        self.homepage = homepage
        self.logo = logo
        self.transportModes = transportModes
    }

    public var description: String {
        "\(String(describing: Self.self))(name: \(name))"
    }
}
