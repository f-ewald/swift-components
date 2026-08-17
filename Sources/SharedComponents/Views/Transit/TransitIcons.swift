//
//  TransitIcons.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 8/17/26.
//

import SwiftUI

/// Pill-shaped styling applied to small transit amenity icons/labels.
public struct TransitIconStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(4)
    }
}

extension View {
    /// Applies the shared pill styling used by transit amenity icons and badges.
    public func transitIconStyle() -> some View {
        modifier(TransitIconStyle())
    }
}

/// A pill-styled bicycle icon indicating bike parking availability.
public struct BikeIcon: View {
    public init() {}

    public var body: some View {
        Image(systemName: "bicycle").transitIconStyle()
    }
}

/// A pill-styled "P" icon indicating car parking availability.
public struct ParkingIcon: View {
    public init() {}

    public var body: some View {
        Text("P").transitIconStyle()
    }
}

/// A pill-styled restroom icon indicating restroom availability.
public struct RestroomIcon: View {
    public init() {}

    public var body: some View {
        Image(systemName: "toilet").transitIconStyle()
    }
}

#Preview {
    HStack {
        BikeIcon()
        ParkingIcon()
        RestroomIcon()
    }
}
