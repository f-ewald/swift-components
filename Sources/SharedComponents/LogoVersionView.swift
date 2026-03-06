//
//  LogoVersionView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/5/26.
//

import SwiftUI

public struct LogoVersionView: View {
    let logo: String
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    
    public init(logo: String) {
        self.logo = logo
    }
    
    public var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Spacer()
            }
            HStack {
                Spacer()
                Text("Version \(version) (\(build))").font(.footnote).foregroundStyle(.tertiary)
                Spacer()
            }
        }
    }
}

#Preview {
    LogoVersionView(logo: "Logo")
}
