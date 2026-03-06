//
//  ErrorView.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/5/26.
//

import SwiftUI

extension View {
    public func errorAlert(message: Binding<String?>) -> some View {
        alert("Error", isPresented: Binding(
            get: { message.wrappedValue != nil },
            set: { if !$0 { message.wrappedValue = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(message.wrappedValue ?? "")
        }
    }
}
