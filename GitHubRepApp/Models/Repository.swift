//
//  Repository.swift
//  GitHubRepApp
//

import Foundation

/// GitHub のリポジトリ情報を表すモデル。
///
/// API レスポンスから必要なフィールドのみをデコードする。null になり得るフィールドは
/// Optional として扱う。
struct Repository: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let fullName: String
    let owner: Owner
    let htmlURL: URL?
    let description: String?
    let language: String?
    let stargazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    let openIssuesCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case owner
        case htmlURL = "html_url"
        case description
        case language
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
    }
}
