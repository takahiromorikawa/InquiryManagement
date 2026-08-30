# backend（InquiryManagement）

問い合わせ管理アプリのバックエンド。Ruby on Rails 7.1（APIモード）+ MySQL。

API 仕様は [`../docs/api.md`](../docs/api.md)、データベース設計は [`../docs/database.md`](../docs/database.md) を参照。

## 前提

- Ruby 3.3.9（[`.ruby-version`](.ruby-version) で固定。rbenv 等で導入）
- MySQL 8.0（リポジトリ直下の [`../docker-compose.yml`](../docker-compose.yml) で起動）

## セットアップ

DB はリポジトリ直下で起動しておく:

```bash
docker compose up -d
```

バックエンド:

```bash
bundle install
bin/rails db:prepare   # 初回のみ（マイグレーション + seed）
bin/rails server       # http://localhost:3000
```

> macOS で `mysql2` gem のビルドに失敗する場合は、Homebrew の MySQL クライアントを指定する:
> ```bash
> bundle config set --local build.mysql2 "--with-mysql-config=$(brew --prefix mysql@8.0)/bin/mysql_config"
> bundle install
> ```

接続情報は [`config/database.yml`](config/database.yml)。環境変数 `DB_HOST` / `DB_PORT` / `DB_USERNAME` / `DB_PASSWORD` / `DB_NAME` で上書きできる。

## seed データ

`bin/rails db:seed` で担当者（Staff）を3件作成する（[`db/seeds.rb`](db/seeds.rb)）。冪等。

| 氏名 | メールアドレス | パスワード |
|---|---|---|
| 山田 太郎 | yamada@example.com | password |
| 佐藤 花子 | sato@example.com | password |
| 鈴木 一郎 | suzuki@example.com | password |

## テスト

```bash
bin/rails test
```

コントローラの request spec（`test/controllers/`）とモデルのテスト（`test/models/`）がある。

## 構成メモ

- `ApplicationController` で全アクションにデフォルトで認証を要求し（`Authentication` concern）、公開エンドポイント（`POST /inquiries`・`POST /login`）のみ `skip_before_action :require_login` している
- 認証は Rails 標準のセッション（Cookie）ベース。APIモードで既定では外れる Cookie / セッション用ミドルウェアを [`config/application.rb`](config/application.rb) で有効化している
- フロントエンド（`http://localhost:5173`）からの Cookie 付きリクエストを許可するため [`config/initializers/cors.rb`](config/initializers/cors.rb) で `rack-cors` を設定（許可オリジンは環境変数 `FRONTEND_ORIGIN` で変更可能）
- CSRF トークンによる保護は入れていない（ローカル利用前提の MVP。`SameSite=Lax` で運用）
