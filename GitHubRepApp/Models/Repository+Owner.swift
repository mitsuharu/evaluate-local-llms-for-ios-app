import Foundation

struct Repository: Identifiable, Equatable {
    static let fallbackAvatarUrl = URL(string: "https://github.com/avatars/no-avatar.png")

    let id: Int
    let fullName: String
    let owner: Owner
    let htmlUrl: URL
    let description: String?
    let language: String?
    let stargazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    let openIssuesCount: Int

    struct Owner: Equatable {
        let login: String
        let avatarUrl: URL
    }
}

// MARK: - Decodable conformance

extension Repository {
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case owner
        case htmlUrl = "html_url"
        case description
        case language
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        fullName = try container.decode(String.self, forKey: .fullName)
        owner = try container.decode(Owner.Decoded.self, forKey: .owner).toDomain()
        htmlUrl = try {
            let urlString = try container.decode(String.self, forKey: .htmlUrl)
            guard let url = URL(string: urlString) else {
                throw DecodingError.dataCorruptedError(forKey: .htmlUrl, in: container, debugDescription: "Invalid URL")
            }
            return url
        }()
        description = try container.decodeIfPresent(String.self, forKey: .description)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        stargazersCount = try container.decode(Int.self, forKey: .stargazersCount)
        watchersCount = try container.decode(Int.self, forKey: .watchersCount)
        forksCount = try container.decode(Int.self, forKey: .forksCount)
        openIssuesCount = try container.decode(Int.self, forKey: .openIssuesCount)
    }
}

extension Repository.Owner {
    struct Decoded: Decodable {
        let login: String
        let avatarUrl: String

        func toDomain() -> Repository.Owner {
            Repository.Owner(
                login: login,
                avatarUrl: URL(string: avatarUrl) ?? Repository.fallbackAvatarUrl
            )
        }
    }
}
