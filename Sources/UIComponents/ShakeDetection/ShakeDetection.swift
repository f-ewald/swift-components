//
//  ShakeDetection.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/4/26.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

#if os(iOS)
// 1. Extend UIDevice to publish shake notification
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

// 2. Override motionEnded in UIWindow
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

// 3. Create a ViewModifier
public struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void
    
    public func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

// 4. Add a convenience View extension
public extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(DeviceShakeViewModifier(action: action))
    }
}
#endif
#endif
