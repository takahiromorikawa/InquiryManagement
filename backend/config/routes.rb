Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # 担当者ログイン／ログアウト（セッション認証 / UC2, UC7）
  post   "login"  => "sessions#create"
  delete "logout" => "sessions#destroy"

  # 担当者の一覧・追加（管理者のみ / UC8）
  resources :staffs, only: %i[index create]

  # 問い合わせ: 投稿（顧客・認証不要 / UC1）、一覧・詳細（UC3, UC4）、
  # ステータス変更（UC6）、ネストした返信投稿（UC5）。投稿以外は認証必須。
  resources :inquiries, only: %i[index show create update] do
    resources :replies, only: %i[create]
  end
end
