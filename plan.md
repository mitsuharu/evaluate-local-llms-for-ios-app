# GitHub リポジトリ検索アプリ 実装計画

本ドキュメントは実装の進捗を追跡するためのチェックリストです。

## 実装進捗

### 必須要件

| # | 要件 | 状況 |
|---|------|------|
| M1 | キーワードを入力して GitHub のリポジトリを検索できる | ☑ 完了 |
| M2 | 検索結果を一覧で表示する（最低限リポジトリ名 `full_name`） | ☑ 完了 |
| M3 | 一覧の項目を選択すると詳細画面に遷移する | ☑ 完了 |
| M4 | 詳細画面に必須項目を表示（名前/アイコン/言語/Star/Watcher/Fork/Issue） | ☑ 完了 |
| M5 | ロジック層に対する単体テストを実装 | ☑ 完了 |
| M6 | Swift API Design Guidelines に準拠 | ☑ 完了 |
| M7 | 責務分離と安全性（型安全・Optional の適切な扱い・エラーハンドリング） | ☑ 完了 |
| M8 | README を実装方針や内容に応じて更新 | ☑ 完了 |

## アーキテクチャ

MVVM + Repository パターンを採用。依存注入はプロトコル経由。

```
GitHubRepApp/
├── App/
│   └── GitHubRepAppApp.swift      # DI の起点
├── Models/
│   ├── Repository+Owner.swift     # ドメインモデル
│   ├── SearchResponse.swift       # API レスポンス DTO
│   └── APIError.swift             # エラー定義
├── Network/
│   ├── GitHubSearchAPIClient.swift   # GitHub API クライアント（プロトコル + 実装）
│   └── MockGitHubSearchAPIClient.swift # テスト用モック
├── Repositories/
│   ├── RepositoryProvider.swift    # リポジトリ層（プロトコル + 実装）
│   └── MockRepositoryProvider.swift  # テスト用モック
├── ViewModels/
│   ├── SearchViewModel.swift       # 検索/一覧画面の VM
│   └── DetailViewModel.swift       # 詳細画面の VM
├── Views/
│   ├── SearchView.swift            # 検索 + 一覧画面
│   └── DetailView.swift            # 詳細画面
└── Assets.xcassets
```

## 完成チェックリスト

- [x] キーワード検索 → 一覧 → 詳細の一連の流れが動作する
- [x] 詳細画面に必須7項目（名前/アイコン/言語/Star/Watcher/Fork/Issue）が表示される
- [x] 強制アンラップ・`try!`・`as!` を使っていない
- [x] `null` を返しうるフィールドが Optional で扱われている
- [x] 通信エラー・0件・読み込み中の各状態がハンドリングされている
- [x] View / ViewModel / Repository / APIClient の責務が分離されている
- [x] 依存がプロトコルで注入され、テスト時にモック可能になっている
- [x] 単体テストが実装され、ネットワークに実アクセスせずに通る
- [x] 命名が Swift API Design Guidelines に沿っている
- [x] README が整備されている
