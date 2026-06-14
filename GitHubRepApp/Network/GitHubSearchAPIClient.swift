import Foundation

// MARK: - Protocol

protocol GitHubSearchAPIClientInterface: Sendable {
    func searchRepositories(query: String, page: Int) async throws -> SearchResponse
}

// MARK: - Implementation

final class GitHubSearchAPIClient: GitHubSearchAPIClientInterface {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchRepositories(query: String, page: Int = 1) async throws -> SearchResponse {
        guard !query.isEmpty else { throw APIError.invalidQuery }

        var components = URLComponents(string: "https://api.github.com/search/repositories")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)),
            URLQueryItem(name: "per_page", value: "30"),
            URLQueryItem(name: "page", value: String(page)),
        ]

        guard let url = components?.url else { throw APIError.invalidQuery }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
                return decoded
            } catch {
                throw APIError.decoding
            }
        case 403:
            throw APIError.rateLimitExceeded
        case 400:
            throw APIError.invalidQuery
        default:
            throw APIError.server(statusCode: httpResponse.statusCode)
        }
    }
}
