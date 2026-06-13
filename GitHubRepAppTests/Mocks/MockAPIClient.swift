//
//  MockAPIClient.swift
//  GitHubRepAppTests
//

import Foundation
@testable import GitHubRepApp

/// テスト用の `APIClient` モック。要求された URL/レスポンスを記録し、固定の応答を返す。
final class MockAPIClient: APIClient, @unchecked Sendable {
    enum Response {
        case success(Data, HTTPURLResponse)
        case failure(Error)
    }

    private let lock = NSLock()
    private var _capturedRequests: [URLRequest] = []
    var capturedRequests: [URLRequest] {
        lock.lock(); defer { lock.unlock() }
        return _capturedRequests
    }

    var nextResponse: Response

    init(nextResponse: Response) {
        self.nextResponse = nextResponse
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        lock.lock()
        _capturedRequests.append(request)
        let response = nextResponse
        lock.unlock()
        switch response {
        case .success(let data, let httpResponse):
            return (data, httpResponse)
        case .failure(let error):
            throw error
        }
    }
}

extension HTTPURLResponse {
    /// テストで指定したステータスコードを持つ `HTTPURLResponse` を作る。
    /// 失敗時は安全に `HTTPURLResponse()` を返す。
    static func stub(statusCode: Int, url: URL = URL(string: "https://example.com")
                     ?? URL(fileURLWithPath: "/")) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        ) ?? HTTPURLResponse()
    }
}
