import Foundation

@MainActor
final class DetailViewModel: ObservableObject {
    @Published var repository: Repository

    init(repository: Repository) {
        self.repository = repository
    }

    var formattedStarCount: String {
        NumberFormatter.localizedString(from: NSNumber(value: repository.stargazersCount), number: .decimal)
    }

    var formattedWatcherCount: String {
        NumberFormatter.localizedString(from: NSNumber(value: repository.watchersCount), number: .decimal)
    }

    var formattedForkCount: String {
        NumberFormatter.localizedString(from: NSNumber(value: repository.forksCount), number: .decimal)
    }

    var formattedIssueCount: String {
        NumberFormatter.localizedString(from: NSNumber(value: repository.openIssuesCount), number: .decimal)
    }
}
