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

- 開発サーバー: http://localhost:5173 （`vite.config.js` で `strictPort` 指定。競合時は別ポートに切り替えず停止する）
- API のベースURL: 既定は `http://localhost:3000`。変更する場合は `.env.local` に `VITE_API_BASE` を設定する
- ログイン用 seed アカウント: `yamada@example.com` / `sato@example.com` / `suzuki@example.com`（いずれもパスワード `password`）。詳細は [`../backend/README.md`](../backend/README.md)

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

未ログインで要ログイン画面にアクセスすると `/login` にリダイレクトする（`src/router/index.js` の `beforeEach`）。

## ディレクトリ

| パス | 役割 |
|---|---|
| `src/views/` | 画面コンポーネント（S1〜S4） |
| `src/components/` | 共用コンポーネント（`StatusBadge.vue` など） |
| `src/router/index.js` | ルーティングとルートガード |
| `src/stores/auth.js` | ログイン中の担当者情報（Pinia、`sessionStorage` にミラー） |
| `src/lib/api.js` | API 通信ラッパ（`credentials: 'include'`、`ApiError`） |
| `src/lib/format.js` | 日時フォーマット |
| `src/constants.js` | ステータスの表示ラベル |
