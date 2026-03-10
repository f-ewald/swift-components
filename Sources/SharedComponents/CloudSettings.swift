//
//  CloudSettings.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/9/26.
//

import Combine
import Foundation
import SwiftUI

/// Store per-app settings in iCloud.
/// Maximum of 1MB or 512 keys, whichever is less.
///
/// Subclasses declare properties using `@CloudStorage`:
/// ```swift
/// class MySettings: CloudSettings {
///     @CloudStorage("theme", default: "light") var theme: String
///     @CloudStorage("fontSize", default: 14) var fontSize: Int
/// }
/// ```
///
/// `RawRepresentable` enums are also supported — the raw value is stored
/// in iCloud automatically:
/// ```swift
/// enum Theme: String { case light, dark }
///
/// class MySettings: CloudSettings {
///     @CloudStorage("theme", default: .light) var theme: Theme
/// }
/// ```
///
/// Then use it in a SwiftUI view with `@StateObject` or `@ObservedObject`:
/// ```swift
/// struct SettingsView: View {
///     @StateObject private var settings = MySettings()
///
///     var body: some View {
///         Picker("Theme", selection: $settings.theme) {
///             Text("Light").tag("light")
///             Text("Dark").tag("dark")
///         }
///     }
/// }
/// ```
open class CloudSettings: ObservableObject, @unchecked Sendable {

    private var observer: NSObjectProtocol?

    public init() {
        NSUbiquitousKeyValueStore.default.synchronize()

        observer = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default,
            queue: .main
        ) { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    deinit {
        if let observer { NotificationCenter.default.removeObserver(observer) }
    }
}

/// Property wrapper for cloud stored properties.
///
/// Supports primitive plist types (String, Int, Double, Bool, Data, etc.)
/// as well as `RawRepresentable` enums whose `RawValue` is a plist type:
/// ```swift
/// enum Theme: String { case light, dark }
///
/// class MySettings: CloudSettings {
///     @CloudStorage("theme", default: .light) var theme: Theme
/// }
/// ```
@propertyWrapper
public struct CloudStorage<T>: @unchecked Sendable {
    private let key: String
    private let defaultValue: T
    private let store = NSUbiquitousKeyValueStore.default
    private let encode: @Sendable (T) -> Any
    private let decode: @Sendable (Any) -> T?

    public init(_ key: String, default defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
        self.encode = { $0 }
        self.decode = { $0 as? T }
    }

    @available(*, unavailable, message: "Use on a CloudSettings subclass")
    public var wrappedValue: T {
        get { fatalError() }
        set { fatalError() }
    }

    public static subscript<Parent: ObservableObject>(
        _enclosingInstance instance: Parent,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Parent, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<Parent, CloudStorage<T>>
    ) -> T {
        get {
            let wrapper = instance[keyPath: storageKeyPath]
            guard let raw = wrapper.store.object(forKey: wrapper.key) else {
                return wrapper.defaultValue
            }
            return wrapper.decode(raw) ?? wrapper.defaultValue
        }
        set {
            let wrapper = instance[keyPath: storageKeyPath]
            (instance.objectWillChange as? ObservableObjectPublisher)?.send()
            wrapper.store.set(wrapper.encode(newValue), forKey: wrapper.key)
        }
    }
}

extension CloudStorage where T: RawRepresentable & Sendable, T.RawValue: Sendable {
    public init(_ key: String, default defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
        self.encode = { $0.rawValue }
        self.decode = { ($0 as? T.RawValue).flatMap(T.init(rawValue:)) }
    }
}
