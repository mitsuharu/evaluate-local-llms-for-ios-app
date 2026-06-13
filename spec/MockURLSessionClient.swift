import Foundation

/// 単体テスト専用のモッククライアント。実際のネットワーク通信を行わず、定義された結果を返すことで、
/// GitHubRepositoryの単体テストを実現可能にします。
public final class MockURLSessionClient: APICLientProtocol {
    
    // テストで注入したい戻り値を保持するためのクロージャ（またはパブリック変数）
    public var fetchResult: APIResult<MockDecodableResponse>?

    /// 初期化時に、期待する返り値(成功/失敗)を設定できます。
    init(fetchResult: APIResult<MockDecodableResponse>? = nil) {
        self.fetchResult = fetchResult
    }
    
    // 必須要件に準拠したメソッドシグネチャを持つ必要があります。
    public func fetch<T: Decodable>(from url: URL) async -> APIResult<T> {
        guard let result = fetchResult else {
            fatalError("MockURLSessionClient must have a pre-configured fetchResult for testing.")
        }
        
        // Tにキャストできる型を強制的に返す (テスト目的なので安全性を考慮し省略)
        return result as! APIResult<T> 
    }
}

// MARK: - テスト用のデコード可能なモック応答構造体
/// MockURLSessionClientの戻り値として使用するための、Codable準拠のダミーレスポンス。
public struct MockDecodableResponse: Codable {
    let totalCount: Int? = 40
    let incompleteResults: Bool? = false
    // テスト時は固定データを渡すため、Repositoryの配列を保持します。
    var items: [MockRepository]?
}

/// テスト専用のリポジトリモデル（Codable準拠）
public struct MockRepository: Codable, Identifiable {
    let id: String
    let fullName: String
    // M4に必要な全てのフィールドをテストデータとして保持するダミープロパティ群
    let ownerLogin: String?
    let language: String?
    let starCount: Int
    let watcherCount: Int
    let forkCount: Int
    let openIssuesCount: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case owner
        case language
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
    }
    
    // 初期化を簡略化するため、内部で手動初期化できるようにします。
    init(id: String, fullName: String, ownerLogin: String? = nil, language: String? = nil, starCount: Int, watcherCount: Int, forkCount: Int, openIssuesCount: Int) {
        self.id = id
        self.fullName = fullName
        self.ownerLogin = ownerLogin
        self.language = language
        self.starCount = starCount
        self.watcherCount = watcherCount
        self.forkCount = forkCount
        self.openIssuesCount = openIssuesCount
    }

    // Codable準拠のため、ダミーのCodable実装が必要です（実際にはテスト時に無視される前提）。
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
        // 以下省略... テストでの使用を主眼とするため、最小限の実装に留めます。
    }
    
    func encode(to encoder: Encoder) throws {
        fatalError("MockRepository is used for decoding only in tests.")
    }

    /// 実際のアプリケーションで利用する形式に変換するためのメソッド（ロジックの明確化のため）。
    func toDomainModel() -> Repository {
        // ここでのデータマッピングは、必要であれば追加のビジネスルールを記述できます。
        return Repository(id: self.id, fullName: self.fullName, owner: Owner(login: self.ownerLogin, avatarURL: nil), htmlURL: nil, descriptionText: nil, primaryLanguage: self.language, starCount: self.starCount, watcherCount: self.watcherCount, forkCount: self.forkCount, openIssuesCount: self.openIssuesCount)
    }
}
