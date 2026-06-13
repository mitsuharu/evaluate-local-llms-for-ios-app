//
//  RepositorySearchError.swift
//  GitHubRepApp
//

import Foundation

/// リポジトリ検索で発生し得るエラー。
///
/// ユーザー向けメッセージは `localizedDescription` から得る。技術的詳細は分離する。
enum RepositorySearchError: Error, Equatable, Sendable {
    case invalidQuery
    case network(URLError)
    case decoding
    case rateLimitExceeded
    case server(statusCode: Int)
    case unknown
}

extension RepositorySearchError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidQuery:
            return "検索キーワードを入力してください。"
        case .network:
            return "通信エラーが発生しました。ネットワーク接続を確認してください。"
        case .decoding:
            return "サーバーからの応答を解析できませんでした。"
        case .rateLimitExceeded:
            return "短時間に検索しすぎました。しばらく時間をおいて再試行してください。"
        case .server(let statusCode):
            return "サーバーエラー（\(statusCode)）が発生しました。"
        case .unknown:
            return "予期しないエラーが発生しました。"
        }
    }
}
