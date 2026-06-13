//
//  GitHubRepositoryRepositoryTests.swift
//  GitHubRepAppTests
//

import Foundation
import Testing
@testable import GitHubRepApp

@Suite("GitHubRepositoryRepository")
struct GitHubRepositoryRepositoryTests {

    private static let validResponseJSON: Data = {
        let json = """
        {
            "total_count": 1,
            "incomplete_results": false,
            "items": [
                {
                    "id": 1,
                    "full_name": "owner/repo",
                    "owner": { "login": "owner", "avatar_url": "https://example.com/a.png" },
                    "html_url": "https://github.com/owner/repo",
                    "description": null,
                    "language": "Swift",
                    "stargazers_count": 10,
                    "watchers_count": 5,
                    "forks_count": 3,
                    "open_issues_count": 2
                }
            ]
        }
        """
        return Data(json.utf8)
    }()

    @Test("空文字列のクエリは invalidQuery エラー")
    func emptyQueryThrowsInvalidQuery() async {
        let client = MockAPIClient(nextResponse: .success(Self.validResponseJSON, .stub(statusCode: 200)))
        let sut = GitHubRepositoryRepository(apiClient: client)

        await #expect(throws: RepositorySearchError.invalidQuery) {
            _ = try await sut.repositories(matching: "   ", sortedBy: .bestMatch, page: 1, perPage: 30)
        }
        #expect(client.capturedRequests.isEmpty)
    }

    @Test("リクエスト URL に query / page / per_page が正しく入る")
    func buildsExpectedRequestURL() async throws {
        let client = MockAPIClient(nextResponse: .success(Self.validResponseJSON, .stub(statusCode: 200)))
        let sut = GitHubRepositoryRepository(apiClient: client)

        _ = try await sut.repositories(matching: "swift ui", sortedBy: .stars, page: 2, perPage: 50)

        let request = try #require(client.capturedRequests.first)
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let items = components.queryItems ?? []

        #expect(items.contains(URLQueryItem(name: "q", value: "swift ui")))
        #expect(items.contains(URLQueryItem(name: "page", value: "2")))
        #expect(items.contains(URLQueryItem(name: "per_page", value: "50")))
        #expect(items.contains(URLQueryItem(name: "sort", value: "stars")))
        #expect(items.contains(URLQueryItem(name: "order", value: "desc")))

        #expect(request.value(forHTTPHeaderField: "Accept") == "application/vnd.github+json")
        #expect(request.value(forHTTPHeaderField: "X-GitHub-Api-Version") == "2022-11-28")
    }

    @Test("ソート未指定の場合は sort/order クエリを送らない")
    func bestMatchSortOmitsSortAndOrder() async throws {
        let client = MockAPIClient(nextResponse: .success(Self.validResponseJSON, .stub(statusCode: 200)))
        let sut = GitHubRepositoryRepository(apiClient: client)

        _ = try await sut.repositories(matching: "abc", sortedBy: .bestMatch, page: 1, perPage: 30)

        let request = try #require(client.capturedRequests.first)
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let names = (components.queryItems ?? []).map(\.name)
        #expect(!names.contains("sort"))
        #expect(!names.contains("order"))
    }

    @Test("200 系で正常デコードできる")
    func decodesSuccessfulResponse() async throws {
        let client = MockAPIClient(nextResponse: .success(Self.validResponseJSON, .stub(statusCode: 200)))
        let sut = GitHubRepositoryRepository(apiClient: client)

        let response = try await sut.repositories(matching: "x", sortedBy: .bestMatch, page: 1, perPage: 30)
        #expect(response.items.count == 1)
        #expect(response.items.first?.fullName == "owner/repo")
    }

    @Test("HTTP 403 はレート制限エラーに変換される")
    func mapsHTTP403ToRateLimit() async {
        let client = MockAPIClient(nextResponse: .success(Data("{}".utf8), .stub(statusCode: 403)))
        let sut = GitHubRepositoryRepository(apiClient: client)

        await #expect(throws: RepositorySearchError.rateLimitExceeded) {
            _ = try await sut.repositories(matching: "x", sortedBy: .bestMatch, page: 1, perPage: 30)
        }
    }

    @Test("HTTP 500 番台はサーバーエラーに変換される")
    func mapsHTTP500ToServerError() async {
        let client = MockAPIClient(nextResponse: .success(Data("{}".utf8), .stub(statusCode: 503)))
        let sut = GitHubRepositoryRepository(apiClient: client)

        await #expect(throws: RepositorySearchError.server(statusCode: 503)) {
            _ = try await sut.repositories(matching: "x", sortedBy: .bestMatch, page: 1, perPage: 30)
        }
    }

    @Test("URLError は network エラーに変換される")
    func mapsURLErrorToNetwork() async {
        let urlError = URLError(.notConnectedToInternet)
        let client = MockAPIClient(nextResponse: .failure(urlError))
        let sut = GitHubRepositoryRepository(apiClient: client)

        await #expect(throws: RepositorySearchError.network(urlError)) {
            _ = try await sut.repositories(matching: "x", sortedBy: .bestMatch, page: 1, perPage: 30)
        }
    }

    @Test("壊れた JSON は decoding エラーに変換される")
    func mapsBrokenJSONToDecodingError() async {
        let client = MockAPIClient(nextResponse: .success(Data("not json".utf8), .stub(statusCode: 200)))
        let sut = GitHubRepositoryRepository(apiClient: client)

        await #expect(throws: RepositorySearchError.decoding) {
            _ = try await sut.repositories(matching: "x", sortedBy: .bestMatch, page: 1, perPage: 30)
        }
    }
}
