//
//  LogoVersionView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/5/26.
//

import SwiftUI

public struct LogoVersionView<Content: View>: View {
    let logo: String?
    let logoView: Content?
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    
    public init(logo: String) where Content == EmptyView {
        self.logo = logo
        self.logoView = nil
    }
    
    public init(@ViewBuilder logoView: () -> Content) {
        self.logo = nil
        self.logoView = logoView()
    }
    
    public var body: some View {
        VStack {
            HStack {
                Spacer()
                if let logoView {
                    logoView
                } else if let logo {
                    Image(logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                Spacer()
            }
            HStack {
                Spacer()
                Text("Version \(version) (\(build))").font(.footnote).foregroundStyle(.secondary)
                Spacer()
            }
        }
    }
}

#Preview("Image Resource") {
    LogoVersionView(logo: "Logo")
}

#Preview("Subview") {
    LogoVersionView(logoView: { Text("Hello") })
}
