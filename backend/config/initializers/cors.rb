# Be sure to restart your server when you modify this file.

# フロントエンド（Vite: http://localhost:5173）からの Cookie 付きリクエストを許可する。
# 許可オリジンは環境変数 FRONTEND_ORIGIN で上書きできる。
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:5173")

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
