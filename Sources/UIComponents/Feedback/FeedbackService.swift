//
//  FeedbackService.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/4/26.
//

import Foundation

public protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

public enum FeedbackServiceError: Error, Equatable {
    case httpError(statusCode: Int)
}

public struct FeedbackService: Sendable {
    private let url: URL
    private let session: URLSessionProtocol

    public init(url: URL, session: URLSessionProtocol = URLSession.shared) {
        self.url = url
        self.session = session
    }

    public func send(_ feedback: Feedback) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(feedback)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw FeedbackServiceError.httpError(statusCode: -1)
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw FeedbackServiceError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}
