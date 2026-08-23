import Testing
import CoreLocation
@testable import SharedComponents

struct MockGeocodingProvider: GeocodingProviding {
    let addresses: [Address]
    let error: (any Error)?

    init(addresses: [Address] = [], error: (any Error)? = nil) {
        self.addresses = addresses
        self.error = error
    }

    func reverseGeocodeLocation(_ location: CLLocation) async throws -> [Address] {
        if let error { throw error }
        return addresses
    }
}

@Test func testReverseGeocodeReturnsAddressFromProvider() async throws {
    let expected = Address(name: "Apple Park", locality: "Cupertino", administrativeArea: "CA")
    let provider = MockGeocodingProvider(addresses: [expected])
    let geocoder = Geocoder(provider: provider)

    let address = try await geocoder.reverseGeocode(
        coordinate: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)
    )

    #expect(address == expected)
}

@Test func testReverseGeocodeThrowsWhenNoResults() async throws {
    let provider = MockGeocodingProvider(addresses: [])
    let geocoder = Geocoder(provider: provider)

    await #expect(throws: GeocoderError.noResults) {
        try await geocoder.reverseGeocode(
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
        )
    }
}

@Test func testReverseGeocodePropagatesUnderlyingError() async throws {
    struct SomeError: Error, Equatable {}
    let provider = MockGeocodingProvider(error: SomeError())
    let geocoder = Geocoder(provider: provider)

    await #expect(throws: SomeError.self) {
        try await geocoder.reverseGeocode(
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
        )
    }
}
