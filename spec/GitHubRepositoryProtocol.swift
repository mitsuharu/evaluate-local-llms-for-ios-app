import Foundation

/// GitHubリポジトリ検索におけるビジネスロジックの契約（プロトコル）。
/// このプロトコルを採用することで、View/ViewModelは具体的なネットワーク実装に依存せず、
/// 任意のモックオブジェクトでテストすることが可能になります。（DI, Testability）
public protocol GitHubRepositoryProtocol {
    
    /// 指定されたクエリキーワードに基づいてリポジトリを検索し、結果のリストを取得します。
    /// - Parameter keyword: ユーザーが入力した検索キーワード。
    /// - Returns: 成功時は検索結果の配列、失敗時はGitHubAPIError。
    func searchRepositories(by keyword: String) async -> APIResult<[Repository]>
}

// MARK: - 関連プロトコル定義 (再確認のためここに含める)
// GitHubRepositoryはAPICLientProtocolに依存するため、全てのファイルを一つの論理的な場所で管理します。
