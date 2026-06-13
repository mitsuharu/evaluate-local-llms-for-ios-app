//
//  RepositorySortOrder.swift
//  GitHubRepApp
//

import Foundation

/// リポジトリ検索のソート順。
///
/// `sort` パラメータの値に対応する。`bestMatch` はソート未指定（既定の関連度順）。
enum RepositorySortOrder: String, CaseIterable, Identifiable, Sendable {
    case bestMatch
    case stars
    case forks
    case updated

    var id: String { rawValue }

    /// API クエリパラメータとして渡す値。`bestMatch` の場合は `nil`。
    var queryValue: String? {
        switch self {
        case .bestMatch: return nil
        case .stars: return "stars"
        case .forks: return "forks"
        case .updated: return "updated"
        }
    }

    /// 画面表示用ラベル。
    var displayName: String {
        switch self {
        case .bestMatch: return "関連度順"
        case .stars: return "Star 数順"
        case .forks: return "Fork 数順"
        case .updated: return "更新日順"
        }
    }
}
