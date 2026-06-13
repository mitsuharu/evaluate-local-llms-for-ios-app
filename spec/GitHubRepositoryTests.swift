import XCTest
// Import する必要があるモジュール名 (例: YourAppName) を使用してください
// @testable import YourAppName 


final class GitHubRepositoryTests: XCTestCase {

    var mockClient: MockURLSessionClient!
    var repository: GitHubRepository!
    let testKeyword = "Swift"
    let validMockItems: [MockRepository] = [
        MockRepository(id: "1", fullName: "apple/swift", ownerLogin: "apple", language: "Swift", starCount: 2000, watcherCount: 500, forkCount: 300, openIssuesCount: 10),
        MockRepository(id: "2", fullName: "apple-dev/test-project", ownerLogin: "apple-dev", language: "Swift", starCount: 100, watcherCount: 50, forkCount: 10, openIssuesCount: 2)
    ]

    override func setUp() {
        super.setUp()
        // 初期化時に成功するモックレスポンスを設定
        let successfulResponse = MockDecodableResponse(items: validMockItems)
        mockClient = MockURLSessionClient(fetchResult: .success(successfulResponse))
        repository = GitHubRepository(apiClient: mockClient)
    }

    override func tearDown() {
        mockClient = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - 成功ケースのテスト (M2, M6準拠)

    @MainActor
    func testSearchRepositories_successCase() async throws {
        // Arrange
        let expectedResultList = validMockItems.map { $0.toDomainModel() }

        // Act
        let result = await repository.searchRepositories(by: testKeyword)

        // Assert (成功し、正しい数のアイテムが返されているか確認)
        switch result {
        case .success(var repos):
            XCTAssertFalse(repos.isEmpty, "Should return repositories.")
            XCTAssertEqual(repos.count, 2, "Should return the correct number of items.")
            // 返されたデータが、テストで設定したデータと同じ構造を持っていることを確認
            XCTAssertEqual(repos[0].fullName, "apple/swift")
        case .failure(let error):
            XCTFail("Expected success but received error: \(error.localizedDescription)")
        }
    }

    @MainActor
    func testSearchRepositories_emptyResults() async throws {
        // Arrange: 検索結果が空のケースをシミュレートするモックを設定
        let emptyResponse = MockDecodableResponse(items: [])
        mockClient.fetchResult = .success(emptyResponse)

        // Act
        let result = await repository.searchRepositories(by: "nonexistent_keyword")

        // Assert
        switch result {
case .success(let repos):
            XCTAssertTrue(repos.isEmpty, "Should return an empty array when no results are found.")
        case .failure(let error):
            XCTFail("Expected success with empty list but received error: \(error)")
        }
    }

    // MARK: - エラーハンドリングのテスト (M7 必須)

    @MainActor
    func testSearchRepositories_invalidQuery() async throws {
        // Act
        let result = await repository.searchRepositories(by: "   ") // 空文字を渡す

        // Assert
        switch result {
case .success:
            XCTFail("Expected failure for invalid query but succeeded.")
        case .failure(let error):
            guard let apiError = error as? GitHubAPIError else {
                return XCTFail("Expected GitHubAPIError but got \(error)")
            }
            // エラー種別が「無効なクエリ」であることを確認
            if case .invalidQuery(let reason) = apiError {
                XCTAssertTrue(reason.contains("必須") || reason.contains("無効"))
            } else {
                 XCTFail("Expected invalid query error but got \(apiError)")
            }
        }
    }

    @MainActor
    func testSearchRepositories_rateLimitExceeded() async throws {
        // Arrange: 403エラー（レートリミット）をシミュレートするモックを設定
        let rateLimitError = GitHubAPIError.rateLimitExceeded
        mockClient.fetchResult = .failure(rateLimitError)

        // Act
        let result = await repository.searchRepositories(by: testKeyword)

        // Assert
        switch result {
case .success:
            XCTFail("Expected failure due to rate limiting but succeeded.")
        case .failure(let error):
            guard let apiError = error as? GitHubAPIError else {
                return XCTFail("Expected GitHubAPIError but got \(error)")
            }
            // エラー種別がレート制限超過であることを確認
            XCTAssertEqual(apiError, .rateLimitExceeded)
        }
    }

    @MainActor
    func testSearchRepositories_networkFailure() async throws {
        // Arrange: 通信失敗をシミュレートするモックを設定 (例: no connectivity)
        let urlError = URLError(.notConnectedToInternet)
        let networkError = GitHubAPIError.network(urlError)
        mockClient.fetchResult = .failure(networkError)

        // Act
        let result = await repository.searchRepositories(by: testKeyword)

        // Assert
        switch result {
case .success:
            XCTFail("Expected failure due to network error but succeeded.")
        case .failure(let error):
            guard let apiError = error as? GitHubAPIError else {
                return XCTFail("Expected GitHubAPIError but got \(error)")
            }
            // エラー種別がネットワークエラーであることを確認
            if case .network(let underlyingError) = apiError {
                XCTAssertEqual((underlyingError as? URLError)?.code, .notConnectedToInternet)
            } else {
                 XCTFail("Expected network error but got \(apiError)")
            }
        }
    }
}

