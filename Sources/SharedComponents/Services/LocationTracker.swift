//
//  LocationTracker.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 8/22/26.
//

import CoreLocation
import Observation

/// Abstracts CoreLocation access so ``LocationTracker`` can be tested without
/// real hardware or a location permission prompt.
public protocol LocationProviding: Sendable {
    /// The current authorization status, read synchronously (no prompt).
    var authorizationStatus: CLAuthorizationStatus { get }

    /// Requests "When In Use" authorization and suspends until the user
    /// responds. Resolves immediately with the current status if it's
    /// already determined.
    func requestWhenInUseAuthorization() async -> CLAuthorizationStatus

    /// Starts a fresh stream of location updates. Ends when ``stopUpdates()``
    /// is called.
    func locationUpdates() -> AsyncThrowingStream<CLLocation, Error>

    /// Halts any active location updates started by the last call to
    /// ``locationUpdates()``. Safe to call even if not currently updating.
    func stopUpdates()
}

/// Wraps `CLLocationManager`, bridging `CLLocationUpdate.liveUpdates()` into
/// the fixed `AsyncThrowingStream` shape ``LocationProviding`` requires.
public final class SystemLocationProvider: NSObject, LocationProviding, @unchecked Sendable {
    private let manager = CLLocationManager()
    private let lock = NSLock()
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var forwardingTask: Task<Void, Never>?

    override public init() {
        super.init()
        manager.delegate = self

        // Only opt in to background delivery if the host app has actually
        // declared the "location" background mode — setting
        // `allowsBackgroundLocationUpdates` without it throws at runtime.
        if let backgroundModes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String],
           backgroundModes.contains("location") {
            manager.allowsBackgroundLocationUpdates = true
            // Unavailable on watchOS — there's no equivalent auto-pause behavior to opt out of.
            #if !os(watchOS)
            manager.pausesLocationUpdatesAutomatically = false
            #endif
        }
    }

    public var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    public func requestWhenInUseAuthorization() async -> CLAuthorizationStatus {
        guard manager.authorizationStatus == .notDetermined else {
            return manager.authorizationStatus
        }
        return await withCheckedContinuation { continuation in
            lock.lock()
            authorizationContinuation = continuation
            lock.unlock()
            manager.requestWhenInUseAuthorization()
        }
    }

    public func locationUpdates() -> AsyncThrowingStream<CLLocation, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await update in CLLocationUpdate.liveUpdates() {
                        if let location = update.location {
                            continuation.yield(location)
                        }
                        if update.authorizationDenied || update.authorizationDeniedGlobally {
                            continuation.finish(throwing: CLError(.denied))
                            return
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            lock.lock()
            forwardingTask = task
            lock.unlock()
        }
    }

    public func stopUpdates() {
        lock.lock()
        let task = forwardingTask
        forwardingTask = nil
        lock.unlock()
        task?.cancel()
    }
}

extension SystemLocationProvider: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        lock.lock()
        let continuation = authorizationContinuation
        authorizationContinuation = nil
        lock.unlock()
        continuation?.resume(returning: manager.authorizationStatus)
    }
}

/// Tracks the device's location over time, appending every update it
/// receives to ``locations``.
///
/// Call ``start()`` to begin tracking and ``stop()`` to end it. Requesting
/// permission is a separate, explicit step — call ``requestAuthorization()``
/// (e.g. from onboarding/settings UI) before ``start()``; ``start()`` never
/// requests permission on its own.
///
/// `@MainActor`-isolated so it's safe to hold in SwiftUI `@State`.
@MainActor
@Observable
public final class LocationTracker {
    /// Every location received while tracking, oldest first. Append-only and
    /// unbounded — read `.first`/`.last` for the oldest/most-recent fix.
    public private(set) var locations: [CLLocation] = []

    /// The current CoreLocation authorization status. Updates when
    /// ``requestAuthorization()`` resolves.
    public private(set) var authorizationStatus: CLAuthorizationStatus

    @ObservationIgnored
    private let provider: any LocationProviding
    @ObservationIgnored
    private var updatesTask: Task<Void, Never>?

    public init(provider: any LocationProviding = SystemLocationProvider()) {
        self.provider = provider
        self.authorizationStatus = provider.authorizationStatus
    }

    /// Requests "When In Use" location authorization. Not called implicitly
    /// by ``start()``.
    public func requestAuthorization() async {
        authorizationStatus = await provider.requestWhenInUseAuthorization()
    }

    /// Begins appending incoming locations to ``locations``. No-op if
    /// already tracking. Does not request authorization.
    public func start() {
        guard updatesTask == nil else { return }
        updatesTask = Task { [weak self, provider] in
            guard let self else { return }
            do {
                for try await location in provider.locationUpdates() {
                    if Task.isCancelled { break }
                    self.locations.append(location)
                }
            } catch {
                self.authorizationStatus = provider.authorizationStatus
            }
        }
    }

    /// Stops tracking. Safe to call even when not tracking.
    public func stop() {
        updatesTask?.cancel()
        updatesTask = nil
        provider.stopUpdates()
    }

    deinit {
        provider.stopUpdates()
    }
}
