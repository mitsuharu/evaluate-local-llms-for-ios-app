//
//  SearchView.swift
//  GitHubRepApp
//

import SwiftUI

/// 検索 + 一覧画面。
struct SearchView: View {
    @State private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("リポジトリ検索")
                .searchable(
                    text: $viewModel.query,
                    prompt: "リポジトリ名・キーワード"
                )
                .onSubmit(of: .search) {
                    viewModel.search()
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        sortMenu
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView(
                "キーワードで検索",
                systemImage: "magnifyingglass",
                description: Text("GitHub のリポジトリをキーワードで検索します。")
            )
        case .loading:
            VStack(spacing: 12) {
                ProgressView()
                Text("検索中…").foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .results(let items):
            List {
                ForEach(items) { repository in
                    NavigationLink(value: repository) {
                        RepositoryRowView(repository: repository)
                    }
                    .onAppear {
                        viewModel.loadMoreIfNeeded(currentItem: repository)
                    }
                }
                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.refresh()
            }
            .navigationDestination(for: Repository.self) { repository in
                RepositoryDetailView(repository: repository)
            }
        case .empty:
            ContentUnavailableView.search(text: viewModel.query)
        case .failed(let error):
            ContentUnavailableView {
                Label("読み込みに失敗しました", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error.localizedDescription)
            } actions: {
                Button("再試行") {
                    viewModel.search()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("ソート", selection: Binding(
                get: { viewModel.sortOrder },
                set: { viewModel.sortOrder = $0 }
            )) {
                ForEach(RepositorySortOrder.allCases) { order in
                    Text(order.displayName).tag(order)
                }
            }
        } label: {
            Label("ソート", systemImage: "arrow.up.arrow.down")
        }
        .accessibilityLabel("ソート順を変更")
    }
}
