import Foundation

/// GitHub APIからリポジトリデータを取得し、ビジネスルールに基づいたデータ処理を行うクラス。
/// クエリ構築やエラーハンドリングなど、アプリケーションの核となるロジックを持ちます。（Repository Pattern）
public final class GitHubRepository: GitHubRepositoryProtocol {
    
    private let apiClient: APICLientProtocol // 依存性注入 (DI) を利用するプロトコル型
    
    // 初期化時にAPICLientProtocolに依存し、テスト容易性を確保します。
    init(apiClient: APICLientProtocol) {
        self.apiClient = apiClient
    }

    /// 検索キーワードをURLエンコードし、必要なクエリパラメータを設定してAPIを呼び出します。
    public func searchRepositories(by keyword: String) async -> APIResult<[Repository]> {
        // クエリバリデーション (M1, M7)
        guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.invalidQuery(reason: "検索キーワードは必須です。"))
        }
        
        let searchURL = buildSearchURL(for: keyword)
        
        // 1. APIクライアントの実行 (ネットワーク処理の委譲)
        let apiResult: APICLientProtocol.APIResult<SearchResponse> = await apiClient.fetch(from: searchURL)

        switch apiResult {
        case .failure(let error):
            // ネットワーク層で捕捉されたエラーをそのまま返します。
            return .failure(error)
        case .success(let response):
            // 2. ビジネスロジックの実行 (データチェックと変換)
            guard let items = response.items, !items.isEmpty else {
                // 結果が0件の場合も、エラーではなく空配列として処理できるのが望ましいですが、
                // 今回は「結果がない」ことをViewModelに通知するため、一旦成功した空の結果を返します。
                return .success([])
            }

            // 3. モデルの検証と集計（必要であれば）
            // ここでデータをフィルタリングしたり、計算したりするロジックが入る可能性があります。
            
            // 単純にRepository配列として成功を返す
            return .success(items)
        }
    }

    /// GitHub Search repositories APIのエンドポイントに合わせてURLを構築します。
    private func buildSearchURL(for keyword: String) -> URL {
        let baseURL = URL(string: "https://api.github.com/search/repositories")!
        
        // クエリパラメータの構築 (必ずURLエンコードを行う)
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "q", value: keyword), // 検索キーワード
            URLQueryItem(name: "sort", value: "stars") // デフォルトでStar数順にソートする
        ]
        
        guard let url = components.url else {
            // このケースはありえませんが、安全のためエラー処理を行います。
            fatalError("Failed to build URL components for GitHub API.")
        }
        return url
    }
}
