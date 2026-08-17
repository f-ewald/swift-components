//
//  Amenities.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 8/17/26.
//

import SwiftUI

/// A horizontal row of station amenity indicators (parking, bike racks,
/// restrooms, elevator). Only amenities that are present are shown.
public struct Amenities: View {
    private let parkingSpaces: Int
    private let bikeRacks: Int
    private let hasRestrooms: Bool
    private let hasElevator: Bool

    public init(parkingSpaces: Int, bikeRacks: Int, hasRestrooms: Bool, hasElevator: Bool) {
        self.parkingSpaces = parkingSpaces
        self.bikeRacks = bikeRacks
        self.hasRestrooms = hasRestrooms
        self.hasElevator = hasElevator
    }

    public var body: some View {
        HStack(spacing: 8) {
            if parkingSpaces > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "parkingsign.circle.fill")
                    Text("\(parkingSpaces)")
                }
                .font(.footnote)
                .foregroundStyle(.blue)
            }

            if bikeRacks > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "bicycle.circle.fill")
                    Text("\(bikeRacks)")
                }
                .font(.footnote)
                .foregroundStyle(.green)
            }

            if hasRestrooms {
                Image(systemName: "toilet.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.purple)
            }

            if hasElevator {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
        }
    }
}

#Preview {
    Amenities(
        parkingSpaces: 3,
        bikeRacks: 178,
        hasRestrooms: true,
        hasElevator: true
    )
}
