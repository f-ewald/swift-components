//
//  ZoneTextView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 8/17/26.
//

import SwiftUI

/// A pill-styled "Zone N" label, for transit systems with zone-based fares.
public struct ZoneTextView: View {
    private let zone: Int

    public init(zone: Int) {
        self.zone = zone
    }

    public var body: some View {
        Text("Zone \(zone)").transitIconStyle()
    }
}

#Preview {
    ZoneTextView(zone: 1)
}
