//
//  GitHubRepositoryRepository.swift
//  GitHubRepApp
//

import Foundation

/// GitHub の Search repositories API を呼び出す `RepositorySearching` 実装。
struct GitHubRepositoryRepository: RepositorySearching {
    private let apiClient: APIClient
    private let decoder: JSONDecoder
    private let baseURL: URL

    init(
        apiClient: APIClient = URLSessionAPIClient(),
        baseURL: URL = Constants.defaultBaseURL,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.apiClient = apiClient
        self.baseURL = baseURL
        self.decoder = decoder
    }

    enum Constants {
        static let defaultBaseURLString = "https://api.github.com/search/repositories"
        static let defaultBaseURL: URL = {
            if let url = URL(string: defaultBaseURLString) { return url }
            // 定数 URL のため通常到達不能。万一の場合は about:blank へフォールバック。
            return URL(string: "about:blank") ?? URL(fileURLWithPath: "/")
        }()
    }

    func repositories(
        matching query: String,
        sortedBy sort: RepositorySortOrder,
        page: Int,
        perPage: Int
    ) async throws -> SearchResponse {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw RepositorySearchError.invalidQuery
        }

        let request = try makeRequest(query: trimmed, sort: sort, page: page, perPage: perPage)

        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await apiClient.data(for: request)
        } catch let urlError as URLError {
            throw RepositorySearchError.network(urlError)
        } catch let error as RepositorySearchError {
            throw error
        } catch {
            throw RepositorySearchError.unknown
        }

        switch response.statusCode {
        case 200...299:
            do {
                return try decoder.decode(SearchResponse.self, from: data)
            } catch {
                throw RepositorySearchError.decoding
            }
        case 403:
            throw RepositorySearchError.rateLimitExceeded
        default:
            throw RepositorySearchError.server(statusCode: response.statusCode)
        }
    }

    private func makeRequest(
        query: String,
        sort: RepositorySortOrder,
        page: Int,
        perPage: Int
    ) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw RepositorySearchError.invalidQuery
        }
        var items: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        if let sortValue = sort.queryValue {
            items.append(URLQueryItem(name: "sort", value: sortValue))
            items.append(URLQueryItem(name: "order", value: "desc"))
        }
        components.queryItems = items

        guard let url = components.url else {
            throw RepositorySearchError.invalidQuery
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        return request
    }

}
