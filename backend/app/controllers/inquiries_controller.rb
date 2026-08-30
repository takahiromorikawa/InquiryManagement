class InquiriesController < ApplicationController
  # 問い合わせ投稿は顧客がログインせずに行う。一覧・詳細は認証必須。
  skip_before_action :require_login, only: :create

  # GET /inquiries
  # 全問い合わせを受信日時の新しい順で返す（UC3）。
  def index
    inquiries = Inquiry.order(created_at: :desc)
    render json: inquiries.map { |inquiry| list_json(inquiry) }
  end

  # GET /inquiries/:id
  # 問い合わせ本体と、紐づく返信（担当者名つき・古い順）を返す（UC4）。
  def show
    inquiry = Inquiry.includes(replies: :staff).find(params[:id])
    render json: detail_json(inquiry)
  end

  # PATCH /inquiries/:id
  # 対応ステータスを変更する（UC6）。前後関係の制約はない。
  def update
    inquiry = Inquiry.includes(replies: :staff).find(params[:id])
    new_status = params[:status].to_s

    unless Inquiry.statuses.key?(new_status)
      return render json: {
        error: "status は #{Inquiry.statuses.keys.join(' / ')} のいずれかを指定してください"
      }, status: :unprocessable_entity
    end

    inquiry.update!(status: new_status)
    render json: detail_json(inquiry)
  end

  # POST /inquiries
  # 顧客がログイン不要で問い合わせを送信する（UC1）。
  # ステータスはモデルのデフォルトで unhandled になる。
  def create
    inquiry = Inquiry.new(inquiry_params)

    if inquiry.save
      render json: detail_json(inquiry), status: :created
    else
      render json: { errors: inquiry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def inquiry_params
    params.permit(:name, :email, :subject, :body)
  end

  # 一覧用: 受信箱の行に必要な項目だけ。
  def list_json(inquiry)
    inquiry.as_json(only: %i[id subject name status created_at])
  end

  # 詳細用・作成レスポンス用: 本体一式と返信スレッド。
  def detail_json(inquiry)
    inquiry.as_json(only: %i[id name email subject body status created_at]).merge(
      "replies" => inquiry.replies.map do |reply|
        {
          "id" => reply.id,
          "body" => reply.body,
          "staff" => reply.staff&.name,
          "created_at" => reply.created_at
        }
      end
    )
  end
end
