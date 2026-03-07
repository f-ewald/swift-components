//
//  PowerUserView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/7/26.
//

import SwiftUI

public struct PowerUserView: View {
    @State private var heartTapped: Bool = false
    private var appName: String = "the app"
    
    public init(appName: String? = nil) {
        if appName != nil {
            self.appName = appName!
        }
    }
    
    public var body: some View {
        VStack {
            Image(systemName: heartTapped ? "heart.fill" : "heart")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundStyle(.red)
                .scaleEffect(heartTapped ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: heartTapped)
                .onTapGesture {
                    heartTapped.toggle()
                }
            
            Text("You're awesome!")
            Text("Thank you for using \(appName ?? "").")
        }.foregroundStyle(.tertiary)
    }
}

#Preview("With Appname") {
    PowerUserView(appName: "APP")
}

#Preview("Without Appname") {
    PowerUserView()
}
