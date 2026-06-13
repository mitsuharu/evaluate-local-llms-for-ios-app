//
//  SearchViewModelTests.swift
//  GitHubRepAppTests
//

import Foundation
import Testing
@testable import GitHubRepApp

@Suite("SearchViewModel")
@MainActor
struct SearchViewModelTests {

    private func makeRepository(id: Int) -> Repository {
        Repository(
            id: id,
            fullName: "owner/repo-\(id)",
            owner: Owner(login: "owner", avatarURL: nil),
            htmlURL: nil,
            description: nil,
            language: "Swift",
            stargazersCount: id,
            watchersCount: id,
            forksCount: id,
            openIssuesCount: id
        )
    }

    private func makeResponse(items: [Repository], totalCount: Int? = nil) -> SearchResponse {
        SearchResponse(
            totalCount: totalCount ?? items.count,
            incompleteResults: false,
            items: items
        )
    }

    @Test("空クエリで search() を呼んでも idle のまま、検索は走らない")
    func searchWithEmptyQueryStaysIdle() async {
        let searcher = MockRepositorySearcher(defaultResponse: .success(SearchResponse(totalCount: 0, incompleteResults: false, items: [])))
        let sut = SearchViewModel(searcher: searcher)
        sut.query = "   "

        sut.search()
        await Task.yield()

        #expect(sut.state == .idle)
        #expect(searcher.calls.isEmpty)
    }

    @Test("結果が空の場合は empty 状態")
    func emptyResultsLeadsToEmptyState() async throws {
        let searcher = MockRepositorySearcher(defaultResponse: .success(makeResponse(items: [])))
        let sut = SearchViewModel(searcher: searcher)
        sut.query = "no-hits"

        await sut.refresh()

        #expect(sut.state == .empty)
    }

    @Test("成功時は results 状態になり、件数が一致する")
    func successYieldsResultsState() async throws {
        let items = (1...3).map(makeRepository)
        let searcher = MockRepositorySearcher(defaultResponse: .success(makeResponse(items: items, totalCount: 3)))
        let sut = SearchViewModel(searcher: searcher, perPage: 30)
        sut.query = "swift"

        await sut.refresh()

        guard case .results(let resultItems) = sut.state else {
            Issue.record("Expected .results, got \(sut.state)")
            return
        }
        #expect(resultItems.count == 3)
    }

    @Test("エラー時は failed 状態になる")
    func failureYieldsFailedState() async {
        let searcher = MockRepositorySearcher(defaultResponse: .failure(.rateLimitExceeded))
        let sut = SearchViewModel(searcher: searcher)
        sut.query = "x"

        await sut.refresh()

        #expect(sut.state == .failed(.rateLimitExceeded))
    }

    @Test("末尾セル到達で 2 ページ目を読み込み、結果が追記される")
    func loadMoreAppendsNextPage() async throws {
        let page1Items = (1...30).map(makeRepository)
        let page2Items = (31...40).map(makeRepository)
        let searcher = MockRepositorySearcher(defaultResponse: .success(makeResponse(items: [])))
        searcher.responsesByPage[1] = .success(SearchResponse(totalCount: 40, incompleteResults: false, items: page1Items))
        searcher.responsesByPage[2] = .success(SearchResponse(totalCount: 40, incompleteResults: false, items: page2Items))

        let sut = SearchViewModel(searcher: searcher, perPage: 30)
        sut.query = "swift"
        await sut.refresh()

        guard case .results(let first) = sut.state, let lastItem = first.last else {
            Issue.record("Expected .results")
            return
        }
        sut.loadMoreIfNeeded(currentItem: lastItem)
        // ループ内の Task の完了を待つ
        await Task.yield()
        await Task.yield()
        await Task.yield()
        // loadMore 内の API 呼び出し完了を待つため、複数の中断点を経由
        for _ in 0..<10 {
            await Task.yield()
            if case .results(let items) = sut.state, items.count == 40 { break }
        }

        guard case .results(let combined) = sut.state else {
            Issue.record("Expected .results after loadMore")
            return
        }
        #expect(combined.count == 40)
        #expect(searcher.calls.map(\.page) == [1, 2])
    }

    @Test("ソート順の変更で自動的に再検索が走る")
    func changingSortTriggersResearch() async {
        let items = [makeRepository(id: 1)]
        let searcher = MockRepositorySearcher(defaultResponse: .success(makeResponse(items: items, totalCount: 1)))
        let sut = SearchViewModel(searcher: searcher)
        sut.query = "swift"
        await sut.refresh()
        let initialCalls = searcher.calls.count

        sut.sortOrder = .stars

        for _ in 0..<10 {
            await Task.yield()
            if searcher.calls.count > initialCalls { break }
        }
        #expect(searcher.calls.count > initialCalls)
        #expect(searcher.calls.last?.sort == .stars)
    }
}
