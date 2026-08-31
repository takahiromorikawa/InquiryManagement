[« 画面仕様に戻る](screens.md)

# API仕様：InquiryManagement

## 認証方式

担当者ログインは、Railsのセッション（Cookie）ベースの認証とする。ログイン成功時にサーバー側でセッションを発行し、
以降のリクエストはCookieによって担当者を識別する。ログイン不要なエンドポイント（問い合わせ投稿 `POST /inquiries`、
ログイン `POST /login`）以外は、未ログイン状態でアクセスした場合 `{ "error": "ログインが必要です" }` と
`401 Unauthorized` を返す。

`ApplicationController` で全アクションにデフォルトで認証を要求し（secure by default）、公開エンドポイントのみ
個別に除外している。フロントエンド（`http://localhost:5173`）からの Cookie 付きリクエストを許可するため、
`rack-cors` で `credentials: true` を設定している（許可オリジンは環境変数 `FRONTEND_ORIGIN` で上書き可能）。

## エラーレスポンスの形式

| 種類 | ステータス | ボディ |
|---|---|---|
| バリデーション失敗（`POST /inquiries`、返信投稿） | `422` | `{ "errors": ["Name can't be blank", ...] }`（メッセージの配列） |
| ステータス値が不正（`PATCH /inquiries/:id`） | `422` | `{ "error": "status は unhandled / in_progress / completed のいずれかを指定してください" }` |
| 未ログイン | `401` | `{ "error": "ログインが必要です" }` |
| 認証失敗（`POST /login`） | `401` | `{ "error": "メールアドレスまたはパスワードが正しくありません" }` |
| リソースが存在しない | `404` | `{ "error": "リソースが見つかりません" }` |

## エンドポイント一覧

| メソッド | パス | 認証 | 説明 | 対応ユースケース |
|---|---|---|---|---|
| POST | /inquiries | 不要 | 問い合わせを新規登録する | UC1 |
| POST | /login | 不要 | メールアドレス・パスワードでログインする | UC2 |
| DELETE | /logout | 必要 | ログインセッションを終了する | UC7 |
| GET | /inquiries | 必要 | 問い合わせ一覧を取得する | UC3 |
| GET | /inquiries/:id | 必要 | 問い合わせ詳細と返信一覧を取得する | UC4 |
| POST | /inquiries/:inquiry_id/replies | 必要 | 指定した問い合わせに返信を投稿する | UC5 |
| PATCH | /inquiries/:id | 必要 | 問い合わせのステータスを変更する | UC6 |

`PATCH /inquiries/:id` は `PUT` でも同じアクションにルーティングされる。

## 主要エンドポイントの入出力

問い合わせを表す JSON は、詳細形（`detail`）と一覧形（`list`）の2種類がある。

- **detail 形**（`GET /inquiries/:id`・`POST /inquiries`・`PATCH /inquiries/:id` が返す）:
  `id`, `company`, `name`, `email`, `subject`, `body`, `status`, `created_at`, `replies`
  - `replies` は配列で、各要素は `id`, `body`, `staff`（返信した担当者名）, `created_at`。投稿日時の古い順
- **list 形**（`GET /inquiries` が返す配列の各要素）:
  `id`, `subject`, `company`, `name`, `status`, `created_at`

### POST /inquiries（問い合わせ投稿）

- リクエスト: `company`（会社名）, `name`（氏名）, `email`（メールアドレス）, `subject`（件名）, `body`（内容）。上記以外のパラメータは無視する
- レスポンス（成功時）: `201 Created`、登録された問い合わせ（detail 形。`status` は自動的に `unhandled`、`replies` は空配列）
- レスポンス（失敗時）: 未入力項目がある場合 `422` と `{ "errors": [...] }`

### POST /login（ログイン）

- リクエスト: `email`, `password`（`email` の大文字小文字・前後の空白は無視する）
- レスポンス（成功時）: `200 OK`、ログインした担当者の情報（`id`, `name`, `email`）。Cookie にセッション情報が設定される
- レスポンス（失敗時）: 認証失敗時 `401` と `{ "error": "..." }`

### DELETE /logout（ログアウト）

- レスポンス: `204 No Content`（セッションを破棄する）

### GET /inquiries（一覧取得）

- レスポンス: 問い合わせの配列（list 形）。受信日時（`created_at`）の新しい順

### GET /inquiries/:id（詳細取得）

- レスポンス（成功時）: 問い合わせ（detail 形）
- レスポンス（失敗時）: 該当する問い合わせが無い場合 `404` と `{ "error": "..." }`

### POST /inquiries/:inquiry_id/replies（返信投稿）

- リクエスト: `body`（返信内容）
- レスポンス（成功時）: `201 Created`、登録された返信（`id`, `body`, `staff`, `created_at`）。投稿した担当者はログインセッションから特定する
- レスポンス（失敗時）:
  - 本文が未入力の場合 `422` と `{ "errors": [...] }`
  - 対象の問い合わせが無い場合 `404`

### PATCH /inquiries/:id（ステータス変更）

- リクエスト: `status`（`unhandled` / `in_progress` / `completed` のいずれか）
- レスポンス（成功時）: 更新後の問い合わせ（detail 形）
- レスポンス（失敗時）:
  - `status` が3値以外の場合 `422` と `{ "error": "..." }`
  - 対象の問い合わせが無い場合 `404`

## シーケンス図

### 問い合わせ投稿（UC1）

```mermaid
sequenceDiagram
    participant 顧客
    participant Vue as フロントエンド(Vue)
    participant Rails as バックエンド(Rails API)
    participant DB as MySQL

    顧客->>Vue: 問い合わせフォームを入力し送信
    Vue->>Rails: POST /inquiries
    Rails->>DB: INSERT INTO inquiries (status: unhandled)
    DB-->>Rails: 登録結果
    Rails-->>Vue: 201 Created
    Vue-->>顧客: 送信完了メッセージを表示
```

### ログイン〜問い合わせ詳細確認・返信（UC2, UC3, UC4, UC5）

```mermaid
sequenceDiagram
    participant 担当者
    participant Vue as フロントエンド(Vue)
    participant Rails as バックエンド(Rails API)
    participant DB as MySQL

    担当者->>Vue: メールアドレス・パスワードを入力
    Vue->>Rails: POST /login
    Rails->>DB: SELECT staff WHERE email
    DB-->>Rails: 該当staff
    Rails-->>Vue: 200 OK（セッションCookie発行）
    Vue-->>担当者: 一覧画面へ遷移

    Vue->>Rails: GET /inquiries（Cookie付き）
    Rails-->>Vue: 問い合わせ一覧
    担当者->>Vue: 一覧から1件クリック
    Vue->>Rails: GET /inquiries/:id（Cookie付き）
    Rails->>DB: SELECT inquiry, replies WHERE inquiry_id
    DB-->>Rails: 問い合わせ本体＋返信一覧
    Rails-->>Vue: 問い合わせ詳細＋返信スレッド
    Vue-->>担当者: 詳細・返信スレッドを表示

    担当者->>Vue: 返信内容を入力し送信
    Vue->>Rails: POST /inquiries/:id/replies（Cookie付き）
    Rails->>DB: INSERT INTO replies (staff_id: ログイン中の担当者)
    DB-->>Rails: 登録結果
    Rails-->>Vue: 201 Created
    Vue-->>担当者: 返信スレッドに追加表示
```

各エンドポイントに対応する画面は[画面仕様](screens.md)、データ構造は[データベース設計](database.md)を参照。
