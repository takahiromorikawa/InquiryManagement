Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # 担当者ログイン／ログアウト（セッション認証 / UC2, UC7）
  post   "login"  => "sessions#create"
  delete "logout" => "sessions#destroy"

  # 問い合わせ投稿（顧客・認証不要 / UC1）。一覧・詳細などは別Issueで追加する。
  resources :inquiries, only: %i[create]
end
