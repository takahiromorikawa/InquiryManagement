[« 画面仕様に戻る](screens.md)

# 技術スタック：InquiryManagement

[TaskManagement](https://github.com/takahiromorikawa/TaskManagement)とは異なる技術スタックを、あえて選定している（[要件定義書](requirements.md)参照）。

## バックエンド

- Ruby 3.3.9 / Ruby on Rails 7.1（APIモード、`config.api_only = true`）
- MySQL（永続化、`mysql2` gem）
- `has_secure_password`（`bcrypt` gem）による担当者パスワードのハッシュ化
- Rails標準のセッション（Cookie）によるログイン状態の管理。APIモードで既定では外れる
  `ActionDispatch::Cookies` / `Session::CookieStore` を明示的に有効化している（`SameSite=Lax`）
- `rack-cors` によるCORS設定（フロント `http://localhost:5173` からのCookie付きリクエストを許可、`credentials: true`）
- テストは minitest（`bin/rails test`）

## フロントエンド

- Vue.js 3（JavaScript。TypeScript は使わない。`<script setup>` SFC）
- Vite（開発サーバー・ビルドツール）
- Vue Router（画面遷移、未ログイン時のリダイレクト制御）
- Pinia（ログイン中の担当者情報の管理。`sessionStorage` にミラーしてリロードに耐える）
- API通信は `fetch` の薄いラッパ（`src/lib/api.js`。`credentials: 'include'` でCookie送受信）

## データベース

- MySQL 8.0
- ローカル環境はDocker（リポジトリ直下の `docker-compose.yml`、`docker compose up -d`）で起動する
- 接続情報は `backend/config/database.yml`（環境変数で上書き可能）

## ディレクトリ構成の方針

- バックエンド（Rails）とフロントエンド（Vue）は、TaskManagementと同様に単一リポジトリ内の別ディレクトリで管理する（別リポジトリには分けない）
- ポート番号: バックエンド`3000` / フロントエンド`5173`（[CLAUDE.md](../CLAUDE.md)のポート管理ルールに従う）

## 開発フロー・品質管理

- GitHub Issue → ブランチ作成 → Pull Request → マージ、という開発フローはTaskManagementと同様とする
- 静的解析・Lint（RuboCop 等）の導入は別Issueで対応する
