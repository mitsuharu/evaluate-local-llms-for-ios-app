import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var repositories: [Repository] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let repositoryProvider: RepositoryProviderInterface
    private var debouncer: Debouncer?

    init(repositoryProvider: RepositoryProviderInterface) {
        self.repositoryProvider = repositoryProvider
    }

    func search() {
        debouncer?.cancel()
        debouncer = Debouncer(delay: .seconds(500)) { [weak self] in
            guard let self else { return }
            self.performSearch()
        }
    }

    func retry() {
        search()
    }

    private func performSearch() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                let response = try await repositoryProvider.searchRepositories(query: query.trimmingCharacters(in: .whitespacesAndNewlines))
                repositories = response.items
            } catch {
                errorMessage = error.localizedDescription
                repositories = []
            }

            isLoading = false
        }
    }

    var hasResults: Bool {
        !repositories.isEmpty
    }
}

// MARK: - Debouncer

private final class Debouncer: NSObject, NSCopying {
    private let delay: Duration
    private let work: () async -> Void
    private var timer: Timer?

    init(delay: Duration, work: @escaping () async -> Void) {
        self.delay = delay
        self.work = work
    }

    func schedule() {
        cancel()
        timer = Timer.scheduledTimer(withTimeInterval: delay.components.seconds, repeats: false) { [weak self] _ in
            guard let self else { return }
            Task { await self.work() }
        }
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }

    func copy(with _: NSCopying? = nil) -> Any {
        Debouncer(delay: delay, work: work)
    }
}
