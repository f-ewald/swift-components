//
//  HeroView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 4/28/26.
//

import SwiftUI

/// A hero view with title, image and optional description.
public struct HeroView: View {
    let title: String
    let systemName: String
    var description: String? = nil
    
    public init(title: String, systemName: String, description: String? = nil) {
        self.title = title
        self.systemName = systemName
        self.description = description
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Image(systemName: systemName)
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .green.mix(with: .black, by: 0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(.bottom, 16)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 4)
            
            if let description = description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview("With Description") {
    HeroView(
        title: "Example",
        systemName: "star.fill",
        description: "This is a descriptive text"
    )
}

#Preview("Without Description") {
    HeroView(
        title: "Example",
        systemName: "star"
    )
}

#Preview("Long Texts") {
    HeroView(
        title: "This is a super super super super super long title",
        systemName: "star.fill",
        description: "The quick brown fox jumps over the lazy dog. Lorem ipsem. The quick brown fox jumps over the lazy dog. Lorem ipsem."
        
    )
}
