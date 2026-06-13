//
//  RepositoryDecodingTests.swift
//  GitHubRepAppTests
//

import Foundation
import Testing
@testable import GitHubRepApp

@Suite("Repository JSON デコード")
struct RepositoryDecodingTests {

    @Test("代表的なレスポンスを SearchResponse にデコードできる")
    func decodesTypicalResponse() throws {
        let json = """
        {
            "total_count": 40,
            "incomplete_results": false,
            "items": [
                {
                    "id": 3081286,
                    "full_name": "dtrupenn/Tetris",
                    "owner": {
                        "login": "dtrupenn",
                        "avatar_url": "https://example.com/avatar.png"
                    },
                    "html_url": "https://github.com/dtrupenn/Tetris",
                    "description": "A C implementation of Tetris.",
                    "language": "Assembly",
                    "stargazers_count": 1,
                    "watchers_count": 1,
                    "forks_count": 0,
                    "open_issues_count": 0
                }
            ]
        }
        """.data(using: .utf8)
        let data = try #require(json)

        let response = try JSONDecoder().decode(SearchResponse.self, from: data)

        #expect(response.totalCount == 40)
        #expect(response.incompleteResults == false)
        #expect(response.items.count == 1)

        let repo = try #require(response.items.first)
        #expect(repo.fullName == "dtrupenn/Tetris")
        #expect(repo.owner.login == "dtrupenn")
        #expect(repo.owner.avatarURL?.absoluteString == "https://example.com/avatar.png")
        #expect(repo.language == "Assembly")
        #expect(repo.stargazersCount == 1)
        #expect(repo.watchersCount == 1)
        #expect(repo.forksCount == 0)
        #expect(repo.openIssuesCount == 0)
    }

    @Test("null になり得るフィールドは Optional として nil でも成功する")
    func decodesNullableFields() throws {
        let json = """
        {
            "total_count": 1,
            "incomplete_results": false,
            "items": [
                {
                    "id": 1,
                    "full_name": "owner/repo",
                    "owner": { "login": "owner", "avatar_url": null },
                    "html_url": null,
                    "description": null,
                    "language": null,
                    "stargazers_count": 0,
                    "watchers_count": 0,
                    "forks_count": 0,
                    "open_issues_count": 0
                }
            ]
        }
        """.data(using: .utf8)
        let data = try #require(json)

        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
        let repo = try #require(response.items.first)
        #expect(repo.owner.avatarURL == nil)
        #expect(repo.htmlURL == nil)
        #expect(repo.description == nil)
        #expect(repo.language == nil)
    }

    @Test("必須フィールドが欠落するとデコードが失敗する")
    func failsWhenRequiredFieldMissing() throws {
        let json = """
        {
            "total_count": 1,
            "incomplete_results": false,
            "items": [
                { "id": 1, "owner": { "login": "x", "avatar_url": null } }
            ]
        }
        """.data(using: .utf8)
        let data = try #require(json)

        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(SearchResponse.self, from: data)
        }
    }
}
