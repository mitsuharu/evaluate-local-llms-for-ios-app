//
//  ContentView.swift
//  GitHubRepApp
//

import SwiftUI

/// アプリのルート View。デフォルトの依存を組み立てて `SearchView` を表示する。
struct ContentView: View {
    var body: some View {
        SearchView(viewModel: SearchViewModel(searcher: GitHubRepositoryRepository()))
    }
}

#Preview {
    ContentView()
}
