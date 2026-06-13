//
//  SearchResponse.swift
//  GitHubRepApp
//

import Foundation

/// Search repositories API のレスポンス構造。
struct SearchResponse: Decodable, Sendable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Repository]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}
