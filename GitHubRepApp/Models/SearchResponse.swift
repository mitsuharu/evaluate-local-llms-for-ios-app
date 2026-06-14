import Foundation

struct SearchResponse: Decodable {
    let totalCount: Int
    let isIncomplete: Bool
    let items: [Repository]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case isIncomplete = "incomplete_results"
        case items
    }
}
