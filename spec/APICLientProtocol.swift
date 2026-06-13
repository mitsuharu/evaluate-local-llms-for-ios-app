import Foundation

/// ネットワーク通信を行うクライアント層の抽象化（Protocol）。
/// これにより、依存性注入(DI)と単体テストが容易になります。
public protocol APICLientProtocol {
    typealias APIResult<T> = Result<T, GitHubAPIError>
    
    /// 指定されたエンドポイントURLからデータを取り出し、指定のCodable型にデコードする非同期メソッド。
    /// - Parameters:
    ///   - url: 完全に構築されエンコードされたURL。
    func fetch<T: Decodable>(from url: URL) async -> APIResult<T>
}
