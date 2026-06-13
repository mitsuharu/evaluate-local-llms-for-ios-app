# GitHub リポジトリ検索アプリ 開発指示書

本ドキュメントは、コード生成 AI に対して iOS アプリの実装を依頼するための指示書です。「必須要件」を満たすことを最優先とし、その上で推奨設計や追加機能に取り組んでください。

実装を開始する前にどのような開発方針で実装を進めていくかを計画 plan.md を作成して、実行するごとに plan.md にチェックを付けて進めてください。

## 課題内容

本アプリは GitHub のリポジトリを検索するアプリです。次の動作を満たすことを課題とします。

### 動作

1. ユーザーが何かしらのキーワードを入力する
2. GitHub の Search repositories API（`GET /search/repositories`）でリポジトリを検索し、結果一覧を概要（リポジトリ名）で表示する
3. 特定の結果を選択したら、該当リポジトリの詳細（リポジトリ名・オーナーアイコン・プロジェクト言語・Star 数・Watcher 数・Fork 数・Issue 数など）を表示する

### 評価の観点

最小構成（検索 → 一覧 → 詳細）を必須とした上で、以下を重視します。

- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) に準拠していること。
- 責務分離と安全性（型安全・Optional の適切な扱い・エラーハンドリング）を意識した設計であること。
- **単体テストが実装されていること（必須）**。
- 上記を満たした上での追加機能の実装を歓迎する。
- 実装内容に応じて、READMEを更新している

## プロジェクト概要

GitHub の [Search repositories API](https://docs.github.com/ja/rest/search/search#search-repositories) を用いて、キーワードでリポジトリを検索し、結果を一覧表示する iOS アプリを開発します。一覧から特定のリポジトリを選択すると、その詳細画面へ遷移します。

最小構成（検索 → 一覧 → 詳細）を**必須**とし、それを満たした上での追加機能の実装を歓迎します。

### アプリの基本フロー

1. ユーザーがキーワードを入力する
2. `GET /search/repositories` でリポジトリを検索する
3. 検索結果を一覧（リポジトリ名）で表示する
4. 一覧から項目を選択すると詳細画面を表示する

---

## 2. 必須要件（Must）

これらを満たすように実装してください。

| # | 要件 |
|---|------|
| M1 | キーワードを入力して GitHub のリポジトリを検索できる |
| M2 | 検索結果を一覧で表示する（最低限リポジトリ名 `full_name`） |
| M3 | 一覧の項目を選択すると詳細画面に遷移する |
| M4 | 詳細画面に以下を表示する：リポジトリ名 / オーナーのアイコン画像 / 主要言語 / Star 数 / Watcher 数 / Fork 数 / Issue 数など |
| M5 | ロジック層に対する**単体テストを実装する**（テストは必須） |
| M6 | [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) に準拠する |
| M7 | 責務分離と安全性（型安全・Optional の適切な扱い・エラーハンドリング）を意識する |
| M8 | README を実装方針や内容に応じて更新する |

### 詳細画面に表示する項目と対応する API フィールド

| 表示項目 | API レスポンスのフィールド |
|----------|---------------------------|
| リポジトリ名 | `full_name` |
| オーナーアイコン | `owner.avatar_url` |
| 主要言語 | `language` |
| Star 数 | `stargazers_count` |
| Watcher 数 | `watchers_count` |
| Fork 数 | `forks_count` |
| Issue 数 | `open_issues_count` |

---

## 3. 技術スタック・開発環境

| 項目 | 指定 |
|------|------|
| 言語 | Swift（最新安定版） |
| UI | SwiftUI または UIKit |
| 外部ライブラリ | オープンソースに限り使用可。ただし **HTTP 通信・JSON デコードは標準ライブラリで実装**することを推奨（依存を最小化） |
| 依存管理 | Swift Package Manager を推奨 |

外部ライブラリを使う場合は「なぜ標準ライブラリではなくそれを選んだか」を README に簡潔に記載してください。

---

## 4. アーキテクチャ・責務分離

機能やレイヤーごとに責務を明確に分離してください。アーキテクチャは MVVM + Repository パターンなど、自身が最適だと考えるものを採用してください。

### 設計上のルール

- View は表示とユーザー入力のみを担当し、ネットワークやデコードのロジックを持たないこと。
- Model は UI フレームワーク非依存のロジックを保持する。
- **依存はプロトコルで注入**し、テスト時にモックへ差し替え可能にすること（Dependency Injection）。
- 各レイヤー間のデータの受け渡しは、明確に定義された型を用いること。

---

## 5. API 仕様

### エンドポイント

```
GET https://api.github.com/search/repositories?q={keyword}
```

### リクエスト

| 項目 | 内容 |
|------|------|
| Header | `Accept: application/vnd.github+json` |
| Header | `X-GitHub-Api-Version: 2022-11-28` |
| Query `q` | 検索キーワード（**必ず URL エンコードすること**） |
| Query `sort`（任意） | `stars` / `forks` / `help-wanted-issues` / `updated` |
| Query `order`（任意） | `desc` / `asc` |
| Query `per_page`（任意） | 1ページの件数（最大 100、デフォルト 30） |
| Query `page`（任意） | ページ番号 |

**注意**: 未認証リクエストのレート制限は **1分あたり10回**です。短時間に連続検索される場合の制御（デバウンス等）を検討してください。トークン認証は本課題では必須としませんが、実装する場合はトークンをソースにハードコードしないこと。

### レスポンス構造（必要な部分の抜粋）

```json
{
  "total_count": 40,
  "incomplete_results": false,
  "items": [
    {
      "id": 3081286,
      "full_name": "dtrupenn/Tetris",
      "owner": {
        "login": "dtrupenn",
        "avatar_url": "https://.../avatar.png"
      },
      "html_url": "https://github.com/dtrupenn/Tetris",
      "description": "A C implementation of Tetris ...",
      "language": "Assembly",
      "stargazers_count": 1,
      "watchers_count": 1,
      "forks_count": 0,
      "open_issues_count": 0
    }
  ]
}
```

## 画面仕様

### 検索 / 一覧画面

- 画面内に検索バー（テキスト入力）を配置する。
- 検索実行で API を呼び出し、`items` を一覧表示する。
- 各セルにはリポジトリ名（`full_name`）を表示する。可能であれば言語・Star 数・説明文なども併記するとよい。
- 状態に応じて表示を切り替える：
  - **初期状態**: 検索を促すプレースホルダ
  - **読み込み中**: ローディングインジケータ
  - **結果あり**: 一覧
  - **結果0件**: 「該当するリポジトリがありません」等のメッセージ
  - **エラー**: エラーメッセージと再試行手段

### 詳細画面

- 一覧で選択したリポジトリの情報を表示する。
- 表示項目は「必須要件 M4」のとおり。
- オーナーアイコンは非同期で画像を読み込む（`AsyncImage` など）。読み込み失敗時のプレースホルダを用意すること。
- 詳細画面内のコンポーネント配置は各自で考えてください

## コーディングガイドライン

### Swift API Design Guidelines 準拠

- 命名は **使用箇所で文として自然に読める**ようにする（例: `repositories(matching:)`）。
- 型・プロトコルは名詞、変更を伴うメソッドは動詞、副作用のないものは名詞形にする。
- 不要な単語を省き、明確さを冗長さより優先する。
- ブール型は断定形で命名する（例: `isEmpty`, `hasResults`）。

### 安全性

- **強制アンラップ（`!`）・強制キャスト（`as!`）・`try!` は原則禁止**。Optional は `guard let` / `if let` / `??` で安全に扱う。
- ネットワーク・デコードの失敗は型付きの `Error`（`enum`）で表現し、握りつぶさない。
- `URLSession` の呼び出し結果（HTTP ステータスコード）を検証し、200 系以外は適切なエラーに変換する。
- `@MainActor` を適切に付与し、UI 更新がメインスレッドで行われることを保証する。

### エラーハンドリング指針

エラー定義の一例です。

```swift
enum RepositorySearchError: Error, Equatable {
    case invalidQuery          // 空文字・不正なキーワード
    case network(URLError)     // 通信失敗
    case decoding             // JSON デコード失敗
    case rateLimitExceeded    // レート制限超過 (HTTP 403)
    case server(statusCode: Int)
    case unknown
}
```

- ユーザーには技術的詳細ではなく、理解可能なメッセージを提示する。
- 可能なら再試行（リトライ）手段を提供する。

### その他

- マジックナンバー・マジックストリングを避け、定数として定義する。
- アクセス修飾子（`private` / `internal` など）を適切に付与し、公開範囲を最小化する。
- 1ファイル1責務を意識し、ファイル・型を適切に分割する。

## 単体テスト（必須）

テスト内容は任意ですが、テストを忘れずに実装してください。

## 追加機能（任意・歓迎）

必須要件を満たした上で、以下のような機能の実装を歓迎します（一部でも可）。

- **ページネーション / 無限スクロール**: `page` パラメータを用いた追加読み込み。
- **ソート切り替え**: Star 数・Fork 数・更新日などでの並び替え UI。
- **画像キャッシュ**: オーナーアイコンのメモリ/ディスクキャッシュ。
- **検索履歴・お気に入り**: ローカル永続化（`UserDefaults` / `SwiftData` など）。
- **ダークモード対応・アクセシビリティ対応**（Dynamic Type、VoiceObject ラベル等）。
- **詳細画面からブラウザで開く**（`html_url` を `SafariViewController` 等で表示）。
- **Pull to Refresh**。
- **UI テスト**（XCUITest）の追加。
- **CI**（GitHub Actions 等）でのビルド・テスト自動化。

追加機能を実装した場合は、README にどの機能を実装したかを明記してください。


## 完成チェックリスト

実装完了前に、以下をすべて確認してください。

- [ ] キーワード検索 → 一覧 → 詳細の一連の流れが動作する
- [ ] 詳細画面に必須7項目（名前/アイコン/言語/Star/Watcher/Fork/Issue）が表示される
- [ ] 強制アンラップ・`try!`・`as!` を使っていない
- [ ] `null` を返しうるフィールドが Optional で扱われている
- [ ] 通信エラー・0件・読み込み中の各状態がハンドリングされている
- [ ] View / ViewModel / Repository / APIClient の責務が分離されている
- [ ] 依存がプロトコルで注入され、テスト時にモック可能になっている
- [ ] 単体テストが実装され、ネットワークに実アクセスせずに通る
- [ ] 命名が Swift API Design Guidelines に沿っている
- [ ] README が整備されている
