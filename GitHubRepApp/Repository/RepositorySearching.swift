//
//  RepositorySearching.swift
//  GitHubRepApp
//

import Foundation

/// リポジトリ検索の抽象化。ViewModel はこのプロトコル経由でデータ層に依存する。
protocol RepositorySearching: Sendable {
    /// 指定したキーワードに合致するリポジトリを検索する。
    ///
    /// - Parameters:
    ///   - query: 検索キーワード（空文字は不可）。
    ///   - sort: ソート順。
    ///   - page: ページ番号（1 始まり）。
    ///   - perPage: 1 ページあたりの件数。
    /// - Returns: 検索結果。
    func repositories(
        matching query: String,
        sortedBy sort: RepositorySortOrder,
        page: Int,
        perPage: Int
    ) async throws -> SearchResponse
}
