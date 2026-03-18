//
//  PowerUserView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/7/26.
//

import SwiftUI

public struct PowerUserView: View {
    @State private var heartTapped: Bool = false
    @State private var isPulsing: Bool = false
    @State private var pulseCount: Int = 0
    private var appName: String = "the app"

    public init(appName: String? = nil) {
        if appName != nil {
            self.appName = appName!
        }
    }

    public var body: some View {
        VStack {
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundStyle(.red)
                .scaleEffect(isPulsing ? 1.3 : (heartTapped ? 1.2 : 1.0))
                .animation(
                    isPulsing
                        ? .easeInOut(duration: 0.4).repeatForever(autoreverses: true)
                        : .spring(response: 0.3, dampingFraction: 0.5),
                    value: isPulsing
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: heartTapped)
                .sensoryFeedback(.impact(weight: .light), trigger: pulseCount)
                .onTapGesture {
                    heartTapped = true
                    isPulsing = true
                    Task {
                        for _ in 0..<7 {
                            try? await Task.sleep(for: .milliseconds(400))
                            pulseCount += 1
                        }
                        isPulsing = false
                    }
                }

            Text("You're awesome!")
            Text("Thank you for using \(appName).")
        }.foregroundStyle(.tertiary)
            .font(.system(size: 12))
    }
}

#Preview("With Appname") {
    PowerUserView(appName: "APP")
}

#Preview("Without Appname") {
    PowerUserView()
}
