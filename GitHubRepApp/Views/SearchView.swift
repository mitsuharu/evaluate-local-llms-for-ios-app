import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel

    init(repositoryProvider: some RepositoryProviderInterface) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(repositoryProvider: repositoryProvider))
    }

    var body: some View {
        NavigationView {
            content
                .navigationTitle("リポジトリ検索")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            searchBar
            resultContent
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("リポジトリ名で検索", text: $viewModel.query, onCommit: viewModel.search)
                .textFieldStyle(.plain)
            Button {
                viewModel.search()
            } label: {
                Text("検索")
                    .foregroundStyle(.white)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .disabled(viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var resultContent: some View {
        if viewModel.isLoading {
            ProgressView("検索中…")
                .frame(maxWidth: .infinity, minHeight: 200)
        } else if let message = viewModel.errorMessage {
            errorContent(message)
        } else if viewModel.hasResults {
            repositoryList
        } else {
            placeholderContent
        }
    }

    private var placeholderContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .imageScale(.large)
                .foregroundStyle(.secondary)
            Text("キーワードを入力して検索")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .imageScale(.large)
                .foregroundStyle(.orange)
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("再試行") {
                viewModel.retry()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .frame(maxWidth: .infinity)
    }

    private var repositoryList: some View {
            List(viewModel.repositories) { repo in
                NavigationLink(destination: DetailView(repository: repo)) {
                    RepositoryRow(repository: repo)
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    SearchView(repositoryProvider: MockRepositoryProvider(apiClient: MockGitHubSearchAPIClient()))
}
