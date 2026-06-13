import Foundation

/// URLSessionを利用して実際のネットワークAPIコールを実行する具体的なクライアント実装。
public final class URLSessionClient: APICLientProtocol {
    
    private let session: URLSession
    
    // 初期化時にURLSessionを注入することで、テストの際にスタブやモックに置き換えやすくします。
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// 指定されたURLからデータを取得し、指定された型Tにデコードするメイン処理。
    public func fetch<T: Decodable>(from url: URL) async -> APIResult<T> {
        print("🌐 Attempting to fetch data from: \(url.absoluteString)")
        
        do {
            // 1. データ取得 (Network Operation)
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.unknown(underlyingError: NSError(domain: "Networking", code: 0)))
            }

            // 2. ステータスコード検証 (HTTP Status Check)
            if !(200...299).contains(httpResponse.statusCode) {
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                var errorToReturn: GitHubAPIError = .serverError(statusCode: httpResponse.statusCode, message: nil)

                switch httpResponse.statusCode {
                case 403: // Forbidden - Rate Limit
                    errorToReturn = .rateLimitExceeded
                default:
                    // その他のサーバーエラーを返す
                    break
                }
                return .failure(errorToReturn)
            }
            
            // 3. JSONデコード (Decoding)
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            return .success(decodedObject)

        } catch let urlError as URLError {
            // URLSession由来の一般的なネットワークエラーをキャッチ
            return .failure(.network(urlError))
        } catch let decodingError as DecodingError {
            // JSONデコードのエラーをキャッチ
            let description = "Decoding failed: \(decodingError.localizedDescription)"
            return .failure(.decoding(description: description))
        } catch {
            // その他予期せぬエラーをキャッチし、安全にラップする
            print("⚠️ Uncaught error during fetch: \(error)")
            return .failure(.unknown(underlyingError: error))
        }
    }
}
