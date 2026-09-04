import Testing
import Foundation
@testable import SharedComponents

@Test func testDepartureStatusScheduledWhenNoEstimate() {
    let departure = Departure(
        id: "1",
        lineID: "line-1",
        headsign: "Millbrae",
        scheduledTime: Date()
    )

    #expect(departure.delay == nil)
    #expect(departure.status == .scheduled)
}

@Test func testDepartureStatusOnTimeWithinTolerance() {
    let scheduled = Date()
    let departure = Departure(
        id: "1",
        lineID: "line-1",
        headsign: "Millbrae",
        scheduledTime: scheduled,
        estimatedTime: scheduled.addingTimeInterval(30)
    )

    #expect(departure.delay == 30)
    #expect(departure.status == .onTime)
}

@Test func testDepartureStatusDelayedBeyondTolerance() {
    let scheduled = Date()
    let departure = Departure(
        id: "1",
        lineID: "line-1",
        headsign: "Millbrae",
        scheduledTime: scheduled,
        estimatedTime: scheduled.addingTimeInterval(300)
    )

    #expect(departure.delay == 300)
    #expect(departure.status == .delayed)
}

@Test func testDepartureStatusEarlyBeyondTolerance() {
    let scheduled = Date()
    let departure = Departure(
        id: "1",
        lineID: "line-1",
        headsign: "Millbrae",
        scheduledTime: scheduled,
        estimatedTime: scheduled.addingTimeInterval(-300)
    )

    #expect(departure.delay == -300)
    #expect(departure.status == .early)
}

@Test func testDepartureStatusCancelledOverridesDelay() {
    let scheduled = Date()
    let departure = Departure(
        id: "1",
        lineID: "line-1",
        headsign: "Millbrae",
        scheduledTime: scheduled,
        estimatedTime: scheduled.addingTimeInterval(300),
        isCancelled: true
    )

    #expect(departure.status == .cancelled)
}
