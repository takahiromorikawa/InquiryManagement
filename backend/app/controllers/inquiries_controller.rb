class InquiriesController < ApplicationController
  # 問い合わせ投稿は顧客がログインせずに行う。
  skip_before_action :require_login, only: :create

  # POST /inquiries
  # 顧客がログイン不要で問い合わせを送信する（UC1）。
  # ステータスはモデルのデフォルトで unhandled になる。
  def create
    inquiry = Inquiry.new(inquiry_params)

    if inquiry.save
      render json: inquiry_json(inquiry), status: :created
    else
      render json: { errors: inquiry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def inquiry_params
    params.permit(:name, :email, :subject, :body)
  end

  def inquiry_json(inquiry)
    inquiry.as_json(only: %i[id name email subject body status created_at])
  end
end
