//
//  RatingsView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/7/26.
//

import SwiftUI
import StoreKit

@Observable
public class AppLaunchState {
    @ObservationIgnored
    @AppStorage("launchCount") public var launchCount: Int = 0
    
    public init(launchCount: Int? = nil) {
        if launchCount != nil {
            self.launchCount = launchCount ?? 0
        }
    }
}

public struct RatingsView: View {
    @Environment(\.requestReview) private var requestReview
    @Environment(AppLaunchState.self) private var appLaunchState
    
    public init() {}
    
    public var body: some View {
        Color.clear
            .onAppear() {
                if appLaunchState.launchCount == 20 {
                    requestReview()
                } else {
                    #if DEBUG
                    print("Launch count is \(appLaunchState.launchCount)")
                    #endif
                }
            }
    }
}
