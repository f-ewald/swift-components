import Testing
import CoreLocation
@testable import SharedComponents

@Test func testCoordinateRoundTripsThroughCLLocationCoordinate2D() {
    let clCoordinate = CLLocationCoordinate2D(latitude: 37.6, longitude: -122.4)
    let coordinate = Coordinate(clCoordinate)

    #expect(coordinate.latitude == clCoordinate.latitude)
    #expect(coordinate.longitude == clCoordinate.longitude)
    #expect(coordinate.clLocationCoordinate.latitude == clCoordinate.latitude)
    #expect(coordinate.clLocationCoordinate.longitude == clCoordinate.longitude)
}

@Test func testTransitStopEqualityComparesCoordinate() {
    let stop1 = TransitStop(
        id: "1",
        name: "Millbrae",
        coordinate: Coordinate(latitude: 37.6, longitude: -122.4),
        operationalState: .normal
    )
    let stop2 = TransitStop(
        id: "1",
        name: "Millbrae",
        coordinate: Coordinate(latitude: 37.6, longitude: -122.4),
        operationalState: .normal
    )
    let movedStop = TransitStop(
        id: "1",
        name: "Millbrae",
        coordinate: Coordinate(latitude: 37.7, longitude: -122.4),
        operationalState: .normal
    )

    #expect(stop1 == stop2)
    #expect(stop1.hashValue == stop2.hashValue)
    #expect(stop1 != movedStop)
}

@Test func testTransitStopAccessibilityConvenienceProperties() {
    let stopWithElevator = TransitStop(
        id: "1",
        name: "Millbrae",
        coordinate: Coordinate(latitude: 37.6, longitude: -122.4),
        operationalState: .normal,
        accessibility: [.elevator]
    )
    let stopWithNothing = TransitStop(
        id: "2",
        name: "Broadway",
        coordinate: Coordinate(latitude: 37.5, longitude: -122.3),
        operationalState: .normal
    )

    #expect(stopWithElevator.hasElevator)
    #expect(!stopWithElevator.hasEscalator)
    #expect(!stopWithNothing.hasElevator)
    #expect(!stopWithNothing.hasEscalator)
}
