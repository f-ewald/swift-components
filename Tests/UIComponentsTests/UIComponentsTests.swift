import Testing
import Foundation
@testable import UIComponents

struct MockURLSession: URLSessionProtocol {
    let data: Data
    let response: URLResponse
    var capturedRequest: URLRequest?
    let error: (any Error)?

    init(
        data: Data = Data(),
        statusCode: Int = 200,
        error: (any Error)? = nil
    ) {
        self.data = data
        self.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        self.error = error
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error { throw error }
        return (data, response)
    }
}

/// Variant that captures the request for inspection
final class CapturingMockURLSession: URLSessionProtocol, @unchecked Sendable {
    var capturedRequest: URLRequest?
    private let mock: MockURLSession

    init(statusCode: Int = 200) {
        self.mock = MockURLSession(statusCode: statusCode)
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedRequest = request
        return try await mock.data(for: request)
    }
}

@Test func testSendEncodesCorrectJSON() async throws {
    let session = CapturingMockURLSession()
    let service = FeedbackService(
        url: URL(string: "https://example.com/feedback")!,
        session: session
    )
    let feedback = Feedback(rating: 4, message: "Great app!")

    try await service.send(feedback)

    let request = try #require(session.capturedRequest)
    #expect(request.httpMethod == "POST")
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

    let body = try #require(request.httpBody)
    let decoded = try JSONDecoder().decode(Feedback.self, from: body)
    #expect(decoded.rating == 4)
    #expect(decoded.message == "Great app!")
}

@Test func testSendThrowsOnNon2xxStatus() async throws {
    let session = MockURLSession(statusCode: 500)
    let service = FeedbackService(
        url: URL(string: "https://example.com/feedback")!,
        session: session
    )

    await #expect(throws: FeedbackServiceError.httpError(statusCode: 500)) {
        try await service.send(Feedback(rating: 1, message: "Bad"))
    }
}

@Test func testSendSucceedsOn200() async throws {
    let session = MockURLSession(statusCode: 200)
    let service = FeedbackService(
        url: URL(string: "https://example.com/feedback")!,
        session: session
    )

    try await service.send(Feedback(rating: 5, message: "Perfect"))
}
