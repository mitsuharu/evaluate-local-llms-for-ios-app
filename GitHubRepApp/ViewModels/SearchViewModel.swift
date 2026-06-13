//
//  SearchViewModel.swift
//  GitHubRepApp
//

import Foundation
import Observation

/// 検索画面の状態管理。
///
/// View からは `state` を観察し、ユーザー操作は `search(query:)` / `loadMore()` などで通知する。
@MainActor
@Observable
final class SearchViewModel {

    /// 画面状態。
    enum ViewState: Equatable {
        case idle
        case loading
        case results([Repository])
        case empty
        case failed(RepositorySearchError)

        var hasResults: Bool {
            if case .results = self { return true }
            return false
        }
    }

    private(set) var state: ViewState = .idle
    private(set) var isLoadingMore = false
    var sortOrder: RepositorySortOrder = .bestMatch {
        didSet {
            guard sortOrder != oldValue else { return }
            performSearch(resettingPagination: true)
        }
    }

    var query: String = ""

    private let searcher: RepositorySearching
    private let perPage: Int
    private var currentPage: Int = 1
    private var currentResults: [Repository] = []
    private var canLoadMore: Bool = false
    private var activeTask: Task<Void, Never>?

    init(searcher: RepositorySearching, perPage: Int = 30) {
        self.searcher = searcher
        self.perPage = perPage
    }

    /// 検索バーの確定操作などで呼び出す。
    func search() {
        performSearch(resettingPagination: true)
    }

    /// Pull to refresh で呼び出す。
    func refresh() async {
        await performSearchAwaiting(resettingPagination: true)
    }

    /// 一覧末尾到達時に呼び出す。次ページを読み込む。
    func loadMoreIfNeeded(currentItem item: Repository) {
        guard case .results(let items) = state else { return }
        guard canLoadMore, !isLoadingMore else { return }
        guard let lastID = items.last?.id, lastID == item.id else { return }
        Task { await loadMore() }
    }

    private func performSearch(resettingPagination: Bool) {
        activeTask?.cancel()
        activeTask = Task { [weak self] in
            await self?.performSearchAwaiting(resettingPagination: resettingPagination)
        }
    }

    private func performSearchAwaiting(resettingPagination: Bool) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            state = .idle
            currentResults = []
            canLoadMore = false
            return
        }

        if resettingPagination {
            currentPage = 1
            currentResults = []
            canLoadMore = false
        }
        state = .loading

        do {
            let response = try await searcher.repositories(
                matching: trimmed,
                sortedBy: sortOrder,
                page: currentPage,
                perPage: perPage
            )
            currentResults = response.items
            canLoadMore = response.items.count == perPage
                && currentResults.count < response.totalCount
            state = currentResults.isEmpty ? .empty : .results(currentResults)
        } catch let error as RepositorySearchError {
            state = .failed(error)
        } catch is CancellationError {
            // タスクがキャンセルされた場合は状態を変更しない。
        } catch {
            state = .failed(.unknown)
        }
    }

    private func loadMore() async {
        guard canLoadMore, !isLoadingMore else { return }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1
        do {
            let response = try await searcher.repositories(
                matching: trimmed,
                sortedBy: sortOrder,
                page: nextPage,
                perPage: perPage
            )
            currentPage = nextPage
            currentResults.append(contentsOf: response.items)
            canLoadMore = response.items.count == perPage
                && currentResults.count < response.totalCount
            state = .results(currentResults)
        } catch {
            // 追加読み込みの失敗は一覧表示を維持し、ログに記録するに留める。
            canLoadMore = false
        }
    }
}
