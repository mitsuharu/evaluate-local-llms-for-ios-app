import Foundation

final class MockGitHubSearchAPIClient: GitHubSearchAPIClientInterface {
    private let delay: UInt64
    private var shouldFail: APIError?

    init(delay: UInt64 = 200, shouldFail: APIError? = nil) {
        self.delay = delay
        self.shouldFail = shouldFail
    }

    func searchRepositories(query: String, page: Int = 1) async throws -> SearchResponse {
        try? await Task.sleep(nanoseconds: delay * 1_000_000)

        if let error = shouldFail {
            throw error
        }

        guard !query.isEmpty else { throw APIError.invalidQuery }

        let items: [Repository] = [
            .mock(
                fullName: "swift/\(query.lowercased())",
                ownerLogin: "swift",
                avatarUrl: "https://github.com/avatars/swift.png",
                language: "Swift",
                stars: 12_345,
                watchers: 1_234,
                forks: 2_345,
                issues: 42
            ),
            .mock(
                fullName: "apple/\(query.lowercased())-sample",
                ownerLogin: "apple",
                avatarUrl: "https://github.com/avatars/apple.png",
                language: "Swift",
                stars: 8_901,
                watchers: 890,
                forks: 567,
                issues: 15
            ),
        ]

        return SearchResponse(totalCount: items.count, isIncomplete: false, items: items)
    }
}

// MARK: - Mock helper

extension Repository {
    static func mock(
        id: Int = 1,
        fullName: String,
        ownerLogin: String,
        avatarUrl: String,
        htmlUrl: String = "https://github.com/\(fullName)",
        description: String? = "A mock repository for \(fullName)",
        language: String?,
        stars: Int,
        watchers: Int,
        forks: Int,
        issues: Int
    ) -> Repository {
        Repository(
            id: id,
            fullName: fullName,
            owner: Owner(login: ownerLogin, avatarUrl: URL(string: avatarUrl) ?? fallbackAvatarUrl),
            htmlUrl: URL(string: htmlUrl) ?? fallbackAvatarUrl,
            description: description,
            language: language,
            stargazersCount: stars,
            watchersCount: watchers,
            forksCount: forks,
            openIssuesCount: issues
        )
    }
}
