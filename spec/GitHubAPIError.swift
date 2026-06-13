import Foundation

/// GitHub APIとの通信やデータ処理中に発生しうるカスタムエラー群。
public enum GitHubAPIError: Error, Equatable {
    case invalidQuery(reason: String)          // 空文字、不正なクエリなどの入力検証エラー
    case network(URLError)                     // 通信レベルのエラー (例: インターネット接続なし)
    case decoding(description: String)         // JSONデコードに失敗した場合
    case rateLimitExceeded                    // APIレート制限超過 (HTTP 403など)
    case serverError(statusCode: Int, message: String?) // サーバーサイドのエラー
    case unknown(underlyingError: Error)        // その他予期せぬエラー
}

extension GitHubAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidQuery(let reason):
            return "検索クエリが無効です: \(reason)"
        case .network(let urlError):
            // ユーザーフレンドリーなメッセージに変換する
            if urlError.code == .notConnectedToInternet {
                return "インターネット接続がありません。再度お試しください。"
            } else if urlError.code == .cannotFindHost {
                 return "ホスト名が見つかりません。ネットワーク設定を確認してください。"
            }
            return "ネットワーク接続エラーが発生しました: \(urlError.localizedDescription)"
        case .decoding(let description):
            return "データ形式が正しくありません。取得したデータを処理できませんでした。\n詳細: \(description)"
        case .rateLimitExceeded:
            return "GitHub APIの利用回数制限を超過しました。しばらく時間を置いてから再度お試しください。"
        case .serverError(let code, _):
            if code == 403 {
                return "APIリクエストが拒否されました (ステータスコード \(code))。権限やクエリを確認してください。"
            }
            return "サーバーエラーが発生しました (ステータスコード: \(code))。"
        case .unknown(let error):
            return "予期せぬエラーが発生しました。詳細はログをご確認ください。\(error.localizedDescription)"
        }
    }
}
