# 担当者のセッション認証を担う。ApplicationController に include し、
# デフォルトで全アクションに require_login を掛ける（secure by default）。
# 公開エンドポイントは各コントローラで skip_before_action :require_login する。
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_login
  end

  private

  def current_staff
    return @current_staff if defined?(@current_staff)

    @current_staff = Staff.find_by(id: session[:staff_id])
  end

  def logged_in?
    current_staff.present?
  end

  def require_login
    return if logged_in?

    render json: { error: "ログインが必要です" }, status: :unauthorized
  end

  # 管理者（admin: true）のみ許可する。未ログインは require_login が先に 401 を返す。
  # ログイン済みだが管理者でない場合は 403 を返す。
  def require_admin
    return if current_staff&.admin?

    render json: { error: "権限がありません" }, status: :forbidden
  end

  def login!(staff)
    reset_session
    session[:staff_id] = staff.id
    @current_staff = staff
  end

  def logout!
    reset_session
    @current_staff = nil
  end
end
