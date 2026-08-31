class SessionsController < ApplicationController
  # ログインは未ログイン状態で叩くため認証をスキップする。
  skip_before_action :require_login, only: :create

  # POST /login — メールアドレス・パスワードで担当者を認証する（UC2）。
  def create
    staff = Staff.find_by(email: params[:email].to_s.strip.downcase)

    if staff&.authenticate(params[:password].to_s)
      login!(staff)
      render json: staff_json(staff)
    else
      render json: { error: "メールアドレスまたはパスワードが正しくありません" }, status: :unauthorized
    end
  end

  # DELETE /logout — ログインセッションを終了する（UC7）。
  def destroy
    logout!
    head :no_content
  end

  private

  def staff_json(staff)
    staff.as_json(only: %i[id name email admin])
  end
end
