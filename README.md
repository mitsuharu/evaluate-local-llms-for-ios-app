# GitHub リポジトリ検索 iOS アプリ

AI（Claude Code）が `spec/index.md` の指示書に基づいて実装した、GitHub リポジトリ検索の iOS / iPadOS / macOS / visionOS アプリです。

## 動作

1. 検索バーにキーワードを入力して送信
2. GitHub の Search repositories API でリポジトリを検索
3. 一覧（リポジトリ名・説明・主要言語・Star・Fork）を表示
4. セルをタップして詳細画面に遷移
5. 詳細画面ではオーナーアイコン、リポジトリ名、主要言語、Star / Watcher / Fork / Issue 数を表示

## 動作環境

- Xcode 26.5
- iOS 26.5 以降
- Swift 5（Swift 6 言語モード / Strict Concurrency 対応）

## アーキテクチャ

MVVM + Repository パターン。依存関係はすべてプロトコル経由で注入し、テスト時はモックに差し替え可能です。

```
View (SwiftUI)
  └── SearchViewModel (@MainActor / @Observable)
        └── RepositorySearching (protocol)
              └── GitHubRepositoryRepository
                    └── APIClient (protocol)
                          └── URLSessionAPIClient
```

### ディレクトリ構成

```
GitHubRepApp/
├── GitHubRepAppApp.swift            // App entry point
├── ContentView.swift                // ルート View（依存注入の組み立て）
├── Models/
│   ├── Repository.swift             // GitHub Repository モデル
│   ├── Owner.swift                  // Owner モデル
│   ├── SearchResponse.swift         // 検索 API レスポンス
│   ├── RepositorySearchError.swift  // 型付きエラー
│   └── RepositorySortOrder.swift    // ソート enum
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

### 設計上の判断

- **HTTP 通信・JSON デコードは標準ライブラリのみ**（`URLSession` / `JSONDecoder`）で実装。仕様で推奨されているため、外部依存を入れていません。
- **強制アンラップ・`try!`・`as!` は使用していません**。Optional は `guard let` / `if let` / `??` で安全に扱います。
- HTTP ステータスを検証し、`200..<300` 以外はエラーに変換します（403 はレート制限、5xx 系は `server(statusCode:)`）。
- `URLError` は `RepositorySearchError.network(_:)` に変換して扱います。
- ViewModel と UI は `@MainActor` で UI 更新がメインスレッドで行われることを保証します。
- 命名は [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) に準拠（例: `repositories(matching:sortedBy:page:perPage:)` / `hasResults`）。

## 実装した追加機能

- **ソート切替**（関連度 / Star / Fork / 更新日）
- **ページネーション / 無限スクロール**（末尾セル到達で次ページを自動読み込み）
- **Pull to Refresh**
- **詳細画面からブラウザで開く**（`html_url`）
- **アクセシビリティ対応**（VoiceOver 用ラベル、Dynamic Type の継承）
- **エラー時の再試行 UI**
- **タスクキャンセル**（新規検索時に進行中の検索を中断）

## 単体テスト

`GitHubRepAppTests/` 配下に Swift Testing フレームワークで実装しています。

| ファイル | 内容 |
|----------|------|
| `RepositoryDecodingTests.swift` | JSON デコードの正常系・null フィールド・必須欠落 |
| `GitHubRepositoryRepositoryTests.swift` | URL 構築、HTTP ステータスのエラー変換、JSON 不正のハンドリング |
| `SearchViewModelTests.swift` | 検索状態遷移、空クエリ、ページネーション、ソート変更時の再検索 |
| `RepositorySearchErrorTests.swift` | エラーケースごとのローカライズメッセージ |
| `Mocks/MockAPIClient.swift` | `APIClient` プロトコルのモック実装 |
| `Mocks/MockRepositorySearcher.swift` | `RepositorySearching` プロトコルのモック実装 |

> **注意**: 現時点ではテストターゲットが Xcode プロジェクトに未追加です。プロジェクトファイルの直接編集を避けるため、Xcode 上で `File > New > Target… > Unit Testing Bundle` から `GitHubRepAppTests` ターゲットを手動で追加し、`GitHubRepAppTests/` フォルダを同期グループとして紐付けてください。

## API 仕様

- エンドポイント: `GET https://api.github.com/search/repositories`
- ヘッダ: `Accept: application/vnd.github+json`, `X-GitHub-Api-Version: 2022-11-28`
- クエリ: `q`（URL エンコードは `URLComponents` が担保） / `page` / `per_page` / `sort` / `order`

未認証時は 1 分あたり 10 回のレート制限があります。403 を受け取った場合は `rateLimitExceeded` エラーとして扱い、再試行を促します。

## 完成チェックリスト

- [x] キーワード検索 → 一覧 → 詳細の一連の流れが動作する
- [x] 詳細画面に必須 7 項目（名前 / アイコン / 言語 / Star / Watcher / Fork / Issue）が表示される
- [x] 強制アンラップ・`try!`・`as!` を使っていない
- [x] `null` を返しうるフィールドが Optional で扱われている
- [x] 通信エラー・0 件・読み込み中の各状態がハンドリングされている
- [x] View / ViewModel / Repository / APIClient の責務が分離されている
- [x] 依存がプロトコルで注入され、テスト時にモック可能になっている
- [x] 単体テスト用コードが実装されている（テストターゲット追加は手動作業）
- [x] 命名が Swift API Design Guidelines に沿っている
- [x] README が整備されている
