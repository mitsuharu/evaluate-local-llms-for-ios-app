import Foundation

// MARK: - Owner Model (必須要件M4)
/// GitHubユーザーの基本情報
public struct Owner: Codable {
    let login: String?             // ログイン名
    let avatarURL: URL?            // オーナーアイコンのURL
}


// MARK: - Repository Model (必須要件M2, M4)
/// 検索結果または詳細画面に表示されるリポジトリの情報
public struct Repository: Codable, Identifiable {
    // CodingKeys を使用して、APIレスポンスのフィールド名と内部でのプロパティ名を分離します。
    private enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case owner
        case htmlURL
        case description
        case language
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
    }

    public var id: String { 
        // full_name (e.g., 'owner/repo')をユニークIDとして使用することが多いですが、ここではAPIの'id'フィールド（数値）を使用し、Identifiableに準拠させます。
        return CodingKeys.id.rawValue ?? UUID().uuidString
    }

    public var fullName: String { 
        // M2で必須とされるフルネーム
        CodingKeys.fullName.rawValue ?? "Unknown Repository"
    }

    public var owner: Owner? { 
        self.owner // Optionalである必要あり
    }

    public var htmlURL: URL? { 
        self.htmlURL // Optionalである必要あり
    }

    public var descriptionText: String? { 
        self.description // Optionalである必要あり
    }
    
    // M4で必須の情報をOptionalで安全に保持するプロパティ群
    public var primaryLanguage: String? { 
        self.language // Optional
    }

    public var starCount: Int? { 
        self.stargazersCount // Optional（デフォルト値が0である可能性が高い）
    }

    public var watcherCount: Int? { 
        self.watchersCount // Optional
    }

    public var forkCount: Int? { 
        self.forksCount // Optional
    }

    public var openIssuesCount: Int? { 
        self.openIssuesCount // Optional
    }
    
    // APIの初期化に必要な全てのフィールドを内部的に処理
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Mandatory fields (optional handling is done via '?' or default values in the struct properties)
        self.id = try container.decode(String.self, forKey: .id)

        // Safe unwrapping for Optional types
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? "N/A"
        self.owner = try container.decodeIfPresent(Owner.self, forKey: .owner)
        self.htmlURL = try container.decodeIfPresent(URL.self, forKey: .htmlURL)

        // Optional fields for data integrity
        self.descriptionText = try container.decodeIfPresent(String.self, forKey: .description)
        self.language = try container.decodeIfPresent(String.self, forKey: .language)
        self.stargazersCount = try container.decodeIfPresent(Int.self, forKey: .stargazersCount) ?? 0
        self.watchersCount = try container.decodeIfPresent(Int.self, forKey: .watchersCount) ?? 0
        self.forkCount = try container.decodeIfPresent(Int.self, forKey: .forksCount) ?? 0
        self.openIssuesCount = try container.decodeIfPresent(Int.self, forKey: .openIssuesCount) ?? 0
    }
}

// MARK: - Search Response Model
/// GitHub APIのレスポンス全体を保持するコンテナ
public struct SearchResponse: Codable {
    let totalCount: Int? // 合計件数
    let incompleteResults: Bool?
    let items: [Repository]? // 検索結果一覧
}
