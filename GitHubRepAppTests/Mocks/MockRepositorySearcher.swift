//
//  MockRepositorySearcher.swift
//  GitHubRepAppTests
//

import Foundation
@testable import GitHubRepApp

/// テスト用の `RepositorySearching` モック。
final class MockRepositorySearcher: RepositorySearching, @unchecked Sendable {
    struct Call: Equatable {
        let query: String
        let sort: RepositorySortOrder
        let page: Int
        let perPage: Int
    }

    enum Response {
        case success(SearchResponse)
        case failure(RepositorySearchError)
    }

    private let lock = NSLock()
    private var _calls: [Call] = []
    var calls: [Call] {
        lock.lock(); defer { lock.unlock() }
        return _calls
    }

    /// page を key にした応答テーブル。未登録の場合は `defaultResponse` を使う。
    var responsesByPage: [Int: Response] = [:]
    var defaultResponse: Response

    init(defaultResponse: Response) {
        self.defaultResponse = defaultResponse
    }

    func repositories(
        matching query: String,
        sortedBy sort: RepositorySortOrder,
        page: Int,
        perPage: Int
    ) async throws -> SearchResponse {
        lock.lock()
        _calls.append(Call(query: query, sort: sort, page: page, perPage: perPage))
        let response = responsesByPage[page] ?? defaultResponse
        lock.unlock()
        switch response {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
