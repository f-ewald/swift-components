//
//  Departure.swift
//  SharedComponents
//
//  Created by Friedrich Ewald on 9/3/26.
//

import Foundation

/// Compass direction a specific trip is traveling, e.g. for
/// "Northbound"/"Southbound" signage. Not every route has a meaningful
/// compass direction (e.g. a loop bus route), so callers that use this
/// should treat it as optional context rather than a required field.
public enum Direction: Sendable, Hashable {
    case north, east, south, west
}

/// Live status of a ``Departure``, derived from its scheduled/estimated
/// times and cancellation flag.
public enum DepartureStatus: Sendable, Hashable {
    /// No live estimate is available yet — only the static schedule is known.
    case scheduled
    case onTime
    case delayed
    case early
    case cancelled
}

/// A single upcoming departure at a stop, e.g. one row of a live "next
/// departures" board. Feed-agnostic — mapping from a specific agency's
/// real-time API happens outside this model.
public struct Departure: Identifiable, Sendable, Hashable {
    public typealias ID = String

    /// Departures within this many seconds of schedule are considered on time.
    private static let onTimeToleranceSeconds: TimeInterval = 60

    public let id: ID
    public let lineID: TransitLine.ID
    public let direction: Direction?
    public let headsign: String
    public let scheduledTime: Date
    public let estimatedTime: Date?
    public let platform: String?
    public let isCancelled: Bool

    public init(
        id: ID,
        lineID: TransitLine.ID,
        direction: Direction? = nil,
        headsign: String,
        scheduledTime: Date,
        estimatedTime: Date? = nil,
        platform: String? = nil,
        isCancelled: Bool = false
    ) {
        self.id = id
        self.lineID = lineID
        self.direction = direction
        self.headsign = headsign
        self.scheduledTime = scheduledTime
        self.estimatedTime = estimatedTime
        self.platform = platform
        self.isCancelled = isCancelled
    }

    /// Positive = running late, negative = running early, `nil` if no live estimate is available.
    public var delay: TimeInterval? {
        estimatedTime.map { $0.timeIntervalSince(scheduledTime) }
    }

    public var status: DepartureStatus {
        guard !isCancelled else { return .cancelled }
        guard let delay else { return .scheduled }
        if delay > Self.onTimeToleranceSeconds { return .delayed }
        if delay < -Self.onTimeToleranceSeconds { return .early }
        return .onTime
    }
}
