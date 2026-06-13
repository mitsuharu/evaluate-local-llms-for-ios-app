//
//  Owner.swift
//  GitHubRepApp
//

import Foundation

/// リポジトリのオーナー情報。
struct Owner: Decodable, Hashable, Sendable {
    let login: String
    let avatarURL: URL?

    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
    }
}
