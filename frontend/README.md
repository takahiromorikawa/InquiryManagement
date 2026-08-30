# frontend（InquiryManagement）

問い合わせ管理アプリのフロントエンド。Vue 3（JavaScript）+ Vite + Vue Router + Pinia。

バックエンド（Rails API）は別ディレクトリ [`../backend`](../backend) で動かす。API 仕様は [`../docs/api.md`](../docs/api.md)、画面仕様は [`../docs/screens.md`](../docs/screens.md) を参照。

## セットアップ

```bash
npm install
```

## 開発

事前にバックエンドと DB を起動しておく（リポジトリ直下で `docker compose up -d`、`cd backend && bin/rails server`）。

```bash
npm run dev
```

- 開発サーバー: http://localhost:5173 （ポート固定。競合時は別ポートに切り替えず停止する）
- API のベースURL: 既定は `http://localhost:3000`。変更する場合は `.env.local` に `VITE_API_BASE` を設定する
- ログイン用 seed アカウント: `yamada@example.com` ほか（パスワード `password`）。詳細は [`../backend/db/seeds.rb`](../backend/db/seeds.rb)

## その他のコマンド

```bash
npm run build     # 本番ビルド
npm run preview   # ビルド結果のプレビュー
```

## 画面とルーティング

| ルート | 画面 | ログイン |
|---|---|---|
| `/` | S1 問い合わせフォーム | 不要 |
| `/login` | S2 ログイン | 不要 |
| `/inquiries` | S3 問い合わせ一覧 | 必要 |
| `/inquiries/:id` | S4 問い合わせ詳細 | 必要 |

未ログインで要ログイン画面にアクセスすると `/login` にリダイレクトする。
