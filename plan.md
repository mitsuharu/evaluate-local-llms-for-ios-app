# 実装計画 (plan.md)

GitHub リポジトリ検索 iOS アプリの実装計画です。spec/index.md の要件に基づき、段階的に進めます。

## アーキテクチャ

MVVM + Repository パターンを採用します。

```
View (SwiftUI) ── ViewModel (@MainActor / ObservableObject)
                      └── RepositorySearching (protocol)
                              └── GitHubRepositoryRepository (URLSession 経由で API 呼び出し)
                                      └── APIClient (protocol)
                                              └── URLSessionAPIClient
```

依存はプロトコル経由で注入し、テスト時はモックに差し替え可能にします。

## ディレクトリ構成

```
GitHubRepApp/
├── GitHubRepAppApp.swift            // App entry point
├── ContentView.swift                // ルート View（SearchView を表示）
├── Models/
│   ├── Repository.swift             // GitHub Repository モデル
│   ├── Owner.swift                  // Owner モデル
│   ├── SearchResponse.swift         // 検索 API レスポンス
│   ├── RepositorySearchError.swift  // 型付きエラー
│   └── SortOrder.swift              // ソート用 enum
├── Networking/
│   ├── APIClient.swift              // HTTP 抽象化
│   └── URLSessionAPIClient.swift    // URLSession 実装
├── Repository/
│   ├── RepositorySearching.swift    // 検索リポジトリ抽象化
│   └── GitHubRepositoryRepository.swift
├── ViewModels/
│   └── SearchViewModel.swift        // 検索状態管理
└── Views/
    ├── SearchView.swift             // 検索 + 一覧
    ├── RepositoryRowView.swift      // セル
    └── RepositoryDetailView.swift   // 詳細
```

```
GitHubRepAppTests/
├── RepositorySearchURLBuilderTests.swift
├── RepositoryDecodingTests.swift
├── SearchViewModelTests.swift
└── Mocks/
    ├── MockAPIClient.swift
    └── MockRepositorySearcher.swift
```

## 実装ステップ

- [x] plan.md の作成
- [x] Models 実装（Repository / Owner / SearchResponse / Error / SortOrder）
- [x] Networking 実装（APIClient プロトコル / URLSessionAPIClient）
- [x] Repository 実装（RepositorySearching / GitHubRepositoryRepository）
- [x] ViewModels 実装（SearchViewModel）
- [x] Views 実装（SearchView / RepositoryRowView / RepositoryDetailView）
- [x] App エントリポイント（ContentView の差し替え）
- [x] 単体テストコード実装（`GitHubRepAppTests/`）
- [ ] **テストターゲットの追加（要手動作業）** - Xcode を開いて `File > New > Target… > Unit Testing Bundle` で `GitHubRepAppTests` ターゲットを追加し、既存の `GitHubRepAppTests/` フォルダを File System Synchronized Group として割り当てる
- [x] アプリ本体のビルド確認
- [ ] テスト実行（テストターゲット追加後）
- [x] README の更新

## 設計上の判断

- HTTP 通信・JSON デコードは標準ライブラリのみ（`URLSession` / `JSONDecoder`）
- `@MainActor` で UI 更新スレッドを保証
- 強制アンラップ・`try!`・`as!` は使用しない
- エラーは `RepositorySearchError` enum で型付け表現
- 検索のデバウンス（500ms）でレート制限への配慮
- ソート切替（stars / forks / updated）、Pull to Refresh を追加機能として実装
