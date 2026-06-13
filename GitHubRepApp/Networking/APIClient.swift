//
//  APIClient.swift
//  GitHubRepApp
//

import Foundation

/// HTTP リクエストを送信し、`Data` と `HTTPURLResponse` を返す抽象化。
///
/// テスト時はモックに差し替えるため、プロトコルを介して依存する。
protocol APIClient: Sendable {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
