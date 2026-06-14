import Foundation

// MARK: - Protocol

protocol RepositoryProviderInterface: Sendable {
    func searchRepositories(query: String, page: Int) async throws -> SearchResponse
}

// MARK: - Implementation

final class RepositoryProvider: RepositoryProviderInterface {
    private let apiClient: GitHubSearchAPIClientInterface

    init(apiClient: GitHubSearchAPIClientInterface) {
        self.apiClient = apiClient
    }

    func searchRepositories(query: String, page: Int) async throws -> SearchResponse {
        try await apiClient.searchRepositories(query: query, page: page)
    }
}

// MARK: - Mock

final class MockRepositoryProvider: RepositoryProviderInterface {
    private let apiClient: GitHubSearchAPIClientInterface

    init(apiClient: GitHubSearchAPIClientInterface) {
        self.apiClient = apiClient
    }

    func searchRepositories(query: String, page: Int) async throws -> SearchResponse {
        try await apiClient.searchRepositories(query: query, page: page)
    }
}
