# InquiryManagement（問い合わせ管理アプリ）

顧客からの問い合わせを担当者が管理・返信するWebアプリケーション。[TaskManagement](https://github.com/takahiromorikawa/TaskManagement)とは異なる技術スタック（Ruby on Rails + Vue.js + MySQL）で、1対多のリレーション（問い合わせと返信）と認証機能（担当者ログイン）を伴う設計・実装を行った。

## 動作確認

<!-- TODO: 実際の動作確認動画・画面キャプチャをここに貼り付ける -->

バックエンド（Rails API）・フロントエンド（Vue）とも MVP の機能一式を実装済み。
一連の操作（問い合わせ投稿 → 担当者ログイン → 一覧・詳細確認 → 返信・ステータス変更）を
確認できる動画・画面キャプチャは今後追加する。ローカルでの起動手順は下記「セットアップ」を参照。

完成イメージの静的モック（HTML/CSS/JS のみ）を [`mock/index.html`](mock/index.html) に置いている
（`cd mock && python3 -m http.server 8080`）。

```mermaid
flowchart LR
    A[顧客] -->|問い合わせ投稿| B[(MySQL)]
    C[担当者] -->|ログイン| D[Vue.js フロントエンド]
    D <-->|API| E[Rails APIバックエンド]
    E <--> B
```

より詳しい画面構成・画面遷移は[画面仕様](docs/screens.md)を参照。

## ドキュメント

| ドキュメント | 内容 |
|---|---|
| [画面仕様](docs/screens.md) | 画面一覧・画面遷移・ワイヤーフレーム（ドキュメントの起点） |
| [要件定義書](docs/requirements.md) | 背景・目的、非機能要件 |
| [機能要件](docs/features.md) | 機能一覧、ユースケース |
| [データベース設計](docs/database.md) | データ項目、ER図 |
| [API仕様](docs/api.md) | エンドポイント一覧、シーケンス図 |
| [技術スタック](docs/tech-stack.md) | 使用技術、ディレクトリ構成の方針 |

## 技術スタック（概要）

| 分類 | 技術 |
|---|---|
| バックエンド | Ruby 3.3.9 / Ruby on Rails 7.1（APIモード） |
| フロントエンド | Vue.js（JavaScript） / Vite / Vue Router / Pinia |
| データベース | MySQL 8.0（Docker Compose で起動） |

詳細は[技術スタック](docs/tech-stack.md)を参照。

## ディレクトリ構成

```
InquiryManagement/
├── backend/            Rails APIバックエンド
├── frontend/           Vue フロントエンド
├── docker-compose.yml  ローカル開発用の MySQL 8.0
└── docs/               設計ドキュメント
```

## セットアップ

### 前提

- Ruby 3.3.9（`backend/.ruby-version` で固定。rbenv 等で導入）
- Docker（MySQL の起動に使用）

### 1. データベースの起動

リポジトリ直下で:

```bash
docker compose up -d
```

MySQL 8.0 が `localhost:3306` で起動する（DB名: `inquiry_management_development` / ユーザー: `root` / パスワード: `password`）。接続情報は [backend/config/database.yml](backend/config/database.yml) を参照。環境変数（`DB_HOST` / `DB_PORT` / `DB_USERNAME` / `DB_PASSWORD` / `DB_NAME`）で上書きできる。

> ローカルに Homebrew などの MySQL が `3306` で起動していると競合する。その場合は停止（例: `brew services stop mysql@8.0`）してから、上記のデフォルトポートで起動し直すこと。

### 2. バックエンドの起動

```bash
cd backend
bundle install
bin/rails db:prepare   # 初回のみ（マイグレーション + seed）
bin/rails server       # http://localhost:3000
```

> macOS で `mysql2` gem のビルドに失敗する場合は、Homebrew の MySQL クライアントを指定する:
> ```bash
> bundle config set --local build.mysql2 "--with-mysql-config=$(brew --prefix mysql@8.0)/bin/mysql_config"
> bundle install
> ```

`bin/rails db:seed` で担当者（Staff）の初期データが3件作成される（ログイン用パスワードはいずれも `password`）。

### 3. フロントエンドの起動

```bash
cd frontend
npm install
npm run dev           # http://localhost:5173
```

詳細は [frontend/README.md](frontend/README.md) を参照。

## 開発フロー

Issue作成 → ブランチ作成 → Pull Request → マージ、という開発フローに従う。詳細は[CLAUDE.md](CLAUDE.md)を参照。
