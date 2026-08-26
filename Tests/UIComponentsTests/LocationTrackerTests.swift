import Testing
import CoreLocation
@testable import SharedComponents

final class MockLocationProvider: LocationProviding, @unchecked Sendable {
    private let locationsToYield: [CLLocation]
    private let authorizationStatusAfterRequest: CLAuthorizationStatus
    private(set) var authorizationStatus: CLAuthorizationStatus
    private(set) var stopCallCount = 0
    private var continuation: AsyncThrowingStream<CLLocation, Error>.Continuation?

    init(
        locationsToYield: [CLLocation],
        initialAuthorizationStatus: CLAuthorizationStatus = .notDetermined,
        authorizationStatusAfterRequest: CLAuthorizationStatus = .authorizedAlways
    ) {
        self.locationsToYield = locationsToYield
        self.authorizationStatus = initialAuthorizationStatus
        self.authorizationStatusAfterRequest = authorizationStatusAfterRequest
    }

    func requestWhenInUseAuthorization() async -> CLAuthorizationStatus {
        authorizationStatus = authorizationStatusAfterRequest
        return authorizationStatus
    }

    func requestAlwaysAuthorization() async -> CLAuthorizationStatus {
        authorizationStatus = authorizationStatusAfterRequest
        return authorizationStatus
    }

    func locationUpdates() -> AsyncThrowingStream<CLLocation, Error> {
        AsyncThrowingStream { continuation in
            self.continuation = continuation
            for location in locationsToYield {
                continuation.yield(location)
            }
            // Deliberately left open (not finished) to simulate a live,
            // ongoing stream that only stopUpdates() ends.
        }
    }

    func stopUpdates() {
        stopCallCount += 1
        continuation?.finish()
        continuation = nil
    }

    func simulateUpdate(_ location: CLLocation) {
        continuation?.yield(location)
    }
}

/// Repeatedly yields until `condition` is true or `timeout` elapses, so tests
/// don't race the forwarding `Task` `LocationTracker.start()` spawns.
@MainActor
private func waitUntil(
    timeout: Duration = .seconds(1),
    _ condition: @MainActor () -> Bool
) async {
    let deadline = ContinuousClock.now + timeout
    while !condition() && ContinuousClock.now < deadline {
        await Task.yield()
    }
}

@MainActor
@Test func testStartAppendsYieldedLocationsToLocations() async throws {
    let first = CLLocation(latitude: 37.3349, longitude: -122.0090)
    let last = CLLocation(latitude: 37.3352, longitude: -122.0095)
    let provider = MockLocationProvider(locationsToYield: [first, last])
    let tracker = LocationTracker(provider: provider)

    tracker.start()
    await waitUntil { tracker.locations.count == 2 }

    #expect(tracker.locations.count == 2)
    #expect(tracker.locations.first === first)
    #expect(tracker.locations.last === last)
}

@MainActor
@Test func testStopHaltsFurtherUpdates() async throws {
    let first = CLLocation(latitude: 37.3349, longitude: -122.0090)
    let provider = MockLocationProvider(locationsToYield: [first])
    let tracker = LocationTracker(provider: provider)

    tracker.start()
    await waitUntil { tracker.locations.count == 1 }
    tracker.stop()

    let countAfterStop = tracker.locations.count
    provider.simulateUpdate(CLLocation(latitude: 0, longitude: 0))
    await Task.yield()

    #expect(tracker.locations.count == countAfterStop)
    #expect(provider.stopCallCount == 1)
}

@MainActor
@Test func testRequestAuthorizationUpdatesAuthorizationStatus() async throws {
    let provider = MockLocationProvider(
        locationsToYield: [],
        initialAuthorizationStatus: .notDetermined,
        authorizationStatusAfterRequest: .authorizedAlways
    )
    let tracker = LocationTracker(provider: provider)

    #expect(tracker.authorizationStatus == .notDetermined)
    #expect(tracker.locations.isEmpty)

    await tracker.requestAuthorization()

    #expect(tracker.authorizationStatus == .authorizedAlways)
    #expect(tracker.locations.isEmpty)
}

@MainActor
@Test func testRequestAlwaysAuthorizationUpdatesAuthorizationStatus() async throws {
    let provider = MockLocationProvider(
        locationsToYield: [],
        initialAuthorizationStatus: .notDetermined,
        authorizationStatusAfterRequest: .authorizedAlways
    )
    let tracker = LocationTracker(provider: provider)

    #expect(tracker.authorizationStatus == .notDetermined)

    await tracker.requestAlwaysAuthorization()

    #expect(tracker.authorizationStatus == .authorizedAlways)
}
