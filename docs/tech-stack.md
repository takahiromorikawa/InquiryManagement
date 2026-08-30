[« 画面仕様に戻る](screens.md)

# 技術スタック：InquiryManagement

[TaskManagement](https://github.com/takahiromorikawa/TaskManagement)とは異なる技術スタックを、あえて選定している（[要件定義書](requirements.md)参照）。

## バックエンド

- Ruby on Rails（APIモード）
- MySQL（永続化）
- has_secure_password（bcrypt）による担当者パスワードのハッシュ化
- Rails標準のセッション（Cookie）によるログイン状態の管理

## フロントエンド

- Vue.js（TypeScript）
- Vite（開発サーバー・ビルドツール）
- Vue Router（画面遷移、未ログイン時のリダイレクト制御）

## データベース

- MySQL
- ローカル環境はDocker（`docker compose`）で起動する

## ディレクトリ構成の方針

- バックエンド（Rails）とフロントエンド（Vue）は、TaskManagementと同様に単一リポジトリ内の別ディレクトリで管理する（別リポジトリには分けない）
- ポート番号: バックエンド`3000` / フロントエンド`5173`（[CLAUDE.md](../CLAUDE.md)のポート管理ルールに従う）

## 開発フロー・品質管理

- GitHub Issue → ブランチ作成 → Pull Request → マージ、という開発フローはTaskManagementと同様とする
- 静的解析・Lintの具体的な導入内容は、環境構築時に確定次第このセクションに追記する
