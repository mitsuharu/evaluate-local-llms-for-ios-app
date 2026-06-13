//
//  URLSessionAPIClient.swift
//  GitHubRepApp
//

import Foundation

/// `URLSession` を用いた `APIClient` の標準実装。
struct URLSessionAPIClient: APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RepositorySearchError.unknown
        }
        return (data, httpResponse)
    }
}
