import Foundation

enum APIError: Error, Equatable, LocalizedError {
    case invalidQuery
    case network(URLError)
    case decoding
    case rateLimitExceeded
    case server(statusCode: Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidQuery:
            return "検索キーワードが入力されていません。"
        case .network(let urlError):
            return urlDescription(from: urlError)
        case .decoding:
            return "サーバーからのデータを解析できませんでした。"
        case .rateLimitExceeded:
            return "ご利用いただける検索回数が一時的に制限されています。数分後に再試行してください。"
        case .server(let statusCode):
            return "サーバーでエラーが発生しました。（HTTP \(statusCode)）"
        case .unknown:
            return "予期しないエラーが発生しました。"
        }
    }

    private func urlDescription(from error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return "インターネットに接続されていません。ネットワーク接続を確認してください。"
        case .secureConnectionFailed:
            return "安全な接続が確立できませんでした。"
        case .timedOut:
            return "接続がタイムアウトしました。後でもう一度お試しください。"
        default:
            return "通信に失敗しました。ネットワーク接続を確認してください。"
        }
    }
}
